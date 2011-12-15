require 'spec_helper'
require 'active_support/cache'
#require 'debug'

# a class whose methods are to be cached
class SomeClass
  include MethodCacher::Base

  @@counter = 0

  def id
    object_id
  end

  caches_method :foo1, :foo2, singleton: [:bar1, :bar2]  #, :obj_key => proc { |s| s.object_id }
  # test instance methods.
  def foo1(*args)
    SomeClass.function(*args)
  end

  def foo2(*args)
    SomeClass.function(*args)
  end

  def foo3(*args)
    SomeClass.function(*args)
  end

  class <<self
    # test singleton (i.e. class) methods.
    def bar1(*args)
     function(*args)
    end

    def bar2(*args)
     function(*args)
    end

    def bar3(*args)
     function(*args)
    end

    # provides a function that returns a different value with each call and bases it on the arguments.
    def function(*args)
      @@counter += 1
      "#{@@counter} #{args}"
    end
  end
end

MethodCacher.caching_strategy = ActiveSupport::Cache.lookup_store(:memory_store)

describe MethodCacher::Base do
  describe "#caches_method" do
    context "when specified before the declaration of the functions to be cached" do
      it "should cache the instance method associated with the names given in the arguments" do
        obj = SomeClass.new
        [:foo1, :foo2].each do |name|
          lambda { obj.send(name) }.should be_twice_the_same
        end
      end

      it "should not cache instance methods whose names are not given in the arguments" do
        obj = SomeClass.new
        lambda { obj.foo3 }.should_not be_twice_the_same
      end

      it "should cache the singleton method associated with the names given in the :singleton option array" do
        [:bar1, :bar2].each do |name|
          lambda { SomeClass.send(name) }.should be_twice_the_same
        end
      end

      it "should not cache singleton methods whose names are not given in the :singleton option" do
        lambda { SomeClass.bar3 }.should_not be_twice_the_same
      end
    end

    context "when cached methods are called with arguments" do
      it "should place an instance method with each set of arguments in a separate cache entry" do
        obj = SomeClass.new
        lambda { obj.foo1(1,2) }.should be_twice_the_same
        lambda { obj.foo1(1,3) }.should be_twice_the_same
        obj.foo1(1,3).should_not == obj.foo1(1,2)
      end

      it "should place a singleton method with each set of arguments in a separate cache entry" do
        lambda { SomeClass.bar1(1,2) }.should be_twice_the_same
        lambda { SomeClass.bar1(1,3) }.should be_twice_the_same
        SomeClass.bar1(1,3).should_not == SomeClass.bar1(1,2)
      end
    end
  end
end