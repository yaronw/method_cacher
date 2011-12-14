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

  caches_method :foo1, :foo2, :foo3 #, :obj_key => proc { |s| s.object_id }
  # Returns a different integer with each call.
  def foo1(*args)
    @counter += 1
  end

  def foo2(*args)
    @counter += 1
  end

  def foo3(*args)
    @counter += 1
  end

  def foo4(*args)
    @counter += 1
  end

  caches_method singleton: :bar
  class <<self
    def bar(*args)
      args << Time.now
    end
  end
end

MethodCacher.caching_strategy = ActiveSupport::Cache.lookup_store(:memory_store)

describe MethodCacher::Base do
  describe "#caches_method" do
    context "when specified before declaration" do
      before (:each) do
        @obj = SomeClass.new
      end

      it "should cache the instance method associated with the given names in the arguments" do
        [:foo1, :foo2, :foo3].each do |name|
          lambda { @obj.send(name) }.should be_twice_the_same
        end
      end

      it "should not cache instance methods whose names are not given in the arguments" do
        lambda { @obj.foo4 }.should_not be_twice_the_same
      end
    end
  end
end