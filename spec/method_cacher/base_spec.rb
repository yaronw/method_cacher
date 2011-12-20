require 'spec_helper'
require 'active_support/cache'
require 'method_cacher/base_test_helper'

describe MethodCacher::Configuration do
  describe "yield style configuration" do
    it "should assign configuration variables" do
      MethodCacher.configure do |c|
        c.caching_strategy = "test1"
      end

      MethodCacher.config.caching_strategy.should == "test1"
    end
  end

  describe "eval style configuration" do
    it "should assign configuration variables" do
      MethodCacher.configure do
        config.caching_strategy = "test2"
      end

      MethodCacher.config.caching_strategy.should == "test2"
    end
  end
end

describe MethodCacher::Base do
  before (:all) do
    MethodCacher.configure do
      config.caching_strategy = ActiveSupport::Cache.lookup_store(:memory_store)
    end
  end

  describe "#caches_method" do
    context "when specified BEFORE the declaration of the functions to be cached" do
      it "should cache the instance method associated with the names given in the arguments" do
        obj = FirstClass.new
        [:foo1, :foo2].each do |name|
          lambda { obj.send(name) }.should be_twice_the_same # verify that original function is not called twice
          obj.send(name).should == Dummy.current_value # verify that the right value is actually cached
        end
      end

      it "should not cache instance methods whose names are not given in the arguments" do
        obj = FirstClass.new
        lambda { obj.foo3 }.should_not be_twice_the_same
      end

      it "should cache the singleton methods associated with the names given in the :singleton option array" do
        [:bar1, :bar2].each do |name|
          lambda { FirstClass.send(name) }.should be_twice_the_same
          FirstClass.send(name).should == Dummy.current_value
        end
      end

      it "should not cache singleton methods whose names are not given in the :singleton option" do
        lambda { FirstClass.bar3 }.should_not be_twice_the_same
      end
    end

    context "when specified AFTER the declaration of the functions to be cached" do
      it "should cache the instance method associated with the names given in the arguments" do
        obj = SecondClass.new
        [:foo1, :foo2].each do |name|
          lambda { obj.send(name) }.should be_twice_the_same
          obj.send(name).should == Dummy.current_value
        end
      end

      it "should not cache instance methods whose names are not given in the arguments" do
        obj = SecondClass.new
        lambda { obj.foo3 }.should_not be_twice_the_same
      end

      it "should cache the singleton methods associated with the names given in the :singleton option array" do
        [:bar1, :bar2].each do |name|
          lambda { SecondClass.send(name) }.should be_twice_the_same
          SecondClass.send(name).should == Dummy.current_value
        end
      end

      it "should not cache singleton methods whose names are not given in the :singleton option" do
        lambda { SecondClass.bar3 }.should_not be_twice_the_same
      end
    end

    describe "cache key mechanism for instance methods" do
      context "when caching an instance method of one object" do
        it "should have different sets of arguments cache separately" do
          obj = FirstClass.new
          lambda { obj.foo1(1,2) }.should be_twice_the_same
          lambda { obj.foo1(1,3) }.should be_twice_the_same
          obj.foo1(1,3).should_not == obj.foo1(1,2)
        end
      end

      context "when caching the same instance method with identical parameter sets and of the same class" do
        it "should have objects whose :obj_key proc evaluates differently cache separately" do
          obj1 = ThirdClass.new
          obj1.obj_key = 1
          obj2 = ThirdClass.new
          obj2.obj_key = 2

          obj1.foo # cache methods
          obj2.foo

          obj2.foo.should_not == obj1.foo
        end

        it "should have objects whose :obj_key proc evaluates the same cache one value" do
          obj1 = ThirdClass.new
          obj1.obj_key = 1
          obj2 = ThirdClass.new
          obj2.obj_key = 1

          obj1.foo # cache methods
          obj2.foo

          obj2.foo.should == obj1.foo
        end
      end

      context "when caching instance methods of identical names with identical parameter sets, and identical :obj_key proc values" do
        it "should have different classes cache separately" do
          obj1 = ThirdClass.new
          obj1.obj_key = 1
          obj2 = FourthClass.new
          obj2.obj_key = 1

          obj1.foo # cache methods
          obj2.foo

          obj2.foo.should_not == obj1.foo
        end
      end

      it "should default the :obj_key option to the instance method named 'id'" do
        # test that the :obj_key mechanism is working for the default 'id' class
        obj1 = FifthClass.new
        obj1.id = 1
        obj2 = FifthClass.new
        obj2.id = 2

        obj1.foo # cache methods
        obj2.foo

        obj2.foo.should_not == obj1.foo
      end

      it "should raise an exception if neither an :obj_key option is given nor the default fallback :id method is defined" do
        obj = SixthClass.new
        lambda { obj.foo }.should raise_error(NoMethodError)
      end
    end

    describe "cache key mechanism for singleton methods" do
      context "when caching a singleton method of one class" do
        it "should have different sets of arguments cache separately" do
          lambda { FirstClass.bar1(1,2) }.should be_twice_the_same
          lambda { FirstClass.bar1(1,3) }.should be_twice_the_same
          FirstClass.bar1(1,3).should_not == FirstClass.bar1(1,2)
        end
      end

      context "when caching singleton methods of identical names with identical parameter sets" do
        it "should have different classes cache separately" do
          ThirdClass.bar # cache methods
          FourthClass.bar

          FourthClass.bar.should_not == ThirdClass.bar
        end
      end
    end

    describe "dynamic methods creation" do
      context "when caching an instance method" do
        it "should include a method named uncached_[name of original method] that calls the original uncached method" do
          obj = FirstClass.new

          # works for methods without arguments
          lambda { obj.uncached_foo1 }.should_not be_twice_the_same # uncached function should not cache      # for testing this assertion: def uncached_#{method_name} \n rand 1000000000 \n end
          obj.uncached_foo1.should == Dummy.current_value  # uncached function should call original method    # for testing this assertion: def uncached_#{method_name} \n 1 \n end

          # works for methods with arguments
          lambda { obj.uncached_foo1(1,2) }.should_not be_twice_the_same # uncached function should not cache
          obj.uncached_foo1(1,2).should == Dummy.current_value(1,2)  # uncached function should call original method
        end

        it "should include a method named clear_cache_for_[name of original method] that clears the cache for a specific method with specific arguments" do
          obj = FirstClass.new

          # works for methods without arguments
          val = obj.foo1
          obj.clear_cache_for_foo1
          obj.foo1.should_not == val

          # works for methods with arguments
          val = obj.foo1(1,2)
          obj.clear_cache_for_foo1(1,2)
          obj.foo1(1,2).should_not == val
        end
      end

      context "when caching a singleton method" do
        it "should include a method that calls the original uncached method" do
          # works for methods without arguments
          lambda { FirstClass.uncached_bar1 }.should_not be_twice_the_same # should not cache
          FirstClass.uncached_bar1.should == Dummy.current_value  # uncached function should call original method

          # works for methods with arguments
          lambda { FirstClass.uncached_bar1(1,2) }.should_not be_twice_the_same # should not cache
          FirstClass.uncached_bar1(1,2).should == Dummy.current_value(1,2)  # uncached function should call original method
        end

        it "should include a method named clear_cache_for_[name of original method] that clears the cache for a specific method with specific arguments" do
          # works for methods without arguments
          val = FirstClass.bar1
          FirstClass.clear_cache_for_bar1
          FirstClass.bar1.should_not == val

          # works for methods with arguments
          val = FirstClass.bar1(1,2)
          FirstClass.clear_cache_for_bar1(1,2)
          FirstClass.bar1(1,2).should_not == val
        end
      end
    end
  end
end