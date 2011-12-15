require 'spec_helper'
require 'active_support/cache'
#require 'debug'


class SomeClass
  include MethodCacher::Base

  def initialize
    @counter = 0
  end

  def id
    object_id
  end

  caches_method :foo1, :foo2 #, :obj_key => proc { |s| s.object_id }
  # Returns a different integer with each call.
  def foo1(*args)
    function(*args)
  end

  def foo2(*args)
    function(*args)
  end

  def foo3(*args)
    function(*args)
  end

  caches_method singleton: :bar1
  class <<self
    def bar(*args)
      args << Time.now
    end
  end

  private
  # Provides a function that returns a different value with each call and bases it on the arguments.
  def function(*args)
    @counter += 1
    "#{@counter} #{args}"
  end

end

MethodCacher.caching_strategy = ActiveSupport::Cache.lookup_store(:memory_store)

describe MethodCacher::Base do
  describe "#caches_method" do
    context "when specified before the declaration of the functions to be cached" do
      before (:each) do
        @obj = SomeClass.new
      end

      it "should cache the instance method associated with the given names in the arguments" do
        [:foo1, :foo2].each do |name|
          lambda { @obj.send(name) }.should be_twice_the_same
        end
      end

      it "should not cache instance methods whose names are not given in the arguments" do
        lambda { @obj.foo3 }.should_not be_twice_the_same
      end

      it "should cache on instance method arguments and place each set of arguments in a separate cache entry" do
        lambda { @obj.foo1(1,2) }.should be_twice_the_same
        lambda { @obj.foo1(1,3) }.should be_twice_the_same
        @obj.foo1(1,3).should_not == @obj.foo1(1,2)
      end
    end
  end
end