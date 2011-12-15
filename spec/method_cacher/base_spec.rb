require 'spec_helper'
require 'active_support/cache'
require 'method_cacher/base_test_helper'
#require 'debug'


MethodCacher.caching_strategy = ActiveSupport::Cache.lookup_store(:memory_store)

describe MethodCacher::Base do
  describe "#caches_method" do
    context "when specified BEFORE the declaration of the functions to be cached" do
      it "should cache the instance method associated with the names given in the arguments" do
        obj = FirstClass.new
        [:foo1, :foo2].each do |name|
          lambda { obj.send(name) }.should be_twice_the_same
        end
      end

      it "should not cache instance methods whose names are not given in the arguments" do
        obj = FirstClass.new
        lambda { obj.foo3 }.should_not be_twice_the_same
      end

      it "should cache the singleton methods associated with the names given in the :singleton option array" do
        [:bar1, :bar2].each do |name|
          lambda { FirstClass.send(name) }.should be_twice_the_same
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
        end
      end

      it "should not cache instance methods whose names are not given in the arguments" do
        obj = SecondClass.new
        lambda { obj.foo3 }.should_not be_twice_the_same
      end

      it "should cache the singleton methods associated with the names given in the :singleton option array" do
        [:bar1, :bar2].each do |name|
          lambda { SecondClass.send(name) }.should be_twice_the_same
        end
      end

      it "should not cache singleton methods whose names are not given in the :singleton option" do
        lambda { SecondClass.bar3 }.should_not be_twice_the_same
      end
    end


    context "when caching an instance method of one object" do
      it "should have different sets of arguments cache separately" do
        obj = FirstClass.new
        lambda { obj.foo1(1,2) }.should be_twice_the_same
        lambda { obj.foo1(1,3) }.should be_twice_the_same
        obj.foo1(1,3).should_not == obj.foo1(1,2)
      end
    end

    context "when caching the same instance method, with identical parameter sets, and of the same class" do
      it "should have objects whose :obj_key proc evaluates differently, cache separately" do
        obj1 = ThirdClass.new
        obj1.obj_key = 1
        obj2 = ThirdClass.new
        obj2.obj_key = 2

        obj1.foo # cache methods
        obj2.foo

        obj2.foo.should_not == obj1.foo
      end

      it "should have objects whose :obj_key proc evaluates the same, cache one value" do
        obj1 = ThirdClass.new
        obj1.obj_key = 1
        obj2 = ThirdClass.new
        obj2.obj_key = 1

        obj1.foo # cache methods
        obj2.foo

        obj2.foo.should == obj1.foo
      end
    end

    context "when caching instance methods of identical names, with identical parameter sets, and identical :obj_key proc values" do
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


    context "when caching a singleton method of one class" do
      it "should have different sets of arguments cache separately" do
        lambda { FirstClass.bar1(1,2) }.should be_twice_the_same
        lambda { FirstClass.bar1(1,3) }.should be_twice_the_same
        FirstClass.bar1(1,3).should_not == FirstClass.bar1(1,2)
      end
    end

    context "when caching singleton methods of identical names, with identical parameter sets" do
      it "should have different classes cache separately" do
        ThirdClass.bar # cache methods
        FourthClass.bar

        FourthClass.bar.should_not == ThirdClass.bar
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

    it "should raise an exception if neither an :obj_key option is given nor a default key is defined"

  end
end