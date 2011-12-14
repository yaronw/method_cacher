require 'spec_helper'
require 'active_support/cache'

class Tester
  include MethodCacher::Base

  def id
    object_id
  end

  caches_method :foo, :obj_key => proc { |s| s.object_id }
  def foo(*args)
    args << Time.now
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
  it "should do something" do
    t = Tester.new
    t.foo
  end
end
