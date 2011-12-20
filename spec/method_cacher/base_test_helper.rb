# Provides a function that returns a different value with each call and also bases the return value on the arguments given.
module Dummy
  @@counter = 0
  def self.function(*args)
    @@counter += 1
    current_value(*args)
  end

  # returns the current value of function without changin it
  def self.current_value(*args)
    "#{@@counter} #{args}"
  end
end

# for testing method caching when caches_method is called before the methods are defined
class FirstClass
  include MethodCacher::Base

  def id
    object_id
  end

  caches_method :foo1, :foo2, singleton: [:bar1, :bar2]  #, :obj_key => proc { |s| s.object_id }
  # test instance methods.
  def foo1(*args)
    Dummy.function(*args)
  end

  def foo2(*args)
    Dummy.function(*args)
  end

  def foo3(*args)
    Dummy.function(*args)
  end

  class <<self
    # test singleton (i.e. class) methods.
    def bar1(*args)
      Dummy.function(*args)
    end

    def bar2(*args)
      Dummy.function(*args)
    end

    def bar3(*args)
      Dummy.function(*args)
    end
  end
end

# for testing method caching when caches_method is called after the methods are defined
class SecondClass
  include MethodCacher::Base

  def id
    object_id
  end

  # test instance methods.
  def foo1
    Dummy.function
  end

  def foo2
    Dummy.function
  end

  def foo3
    Dummy.function
  end

  class <<self
    # test singleton (i.e. class) methods.
    def bar1
      Dummy.function
    end

    def bar2
      Dummy.function
    end

    def bar3
      Dummy.function
    end
  end

  caches_method :foo1, :foo2, singleton: [:bar1, :bar2]
end

# for testing :obj_key option and cache differentiation
class ThirdClass
  include  MethodCacher::Base

  attr_accessor :obj_key

  caches_method :foo, singleton: :bar, obj_key: proc { |obj| obj.obj_key }

  def foo
    Dummy.function
  end

  def self.bar
    Dummy.function
  end
end

# same as previous class
class FourthClass
  include  MethodCacher::Base

  attr_accessor :obj_key

  caches_method :foo, singleton: :bar, obj_key: proc { |obj| obj.obj_key }

  def foo
    Dummy.function
  end

  def self.bar
    Dummy.function
  end
end

# for testing :obj_key option default
class FifthClass
  include  MethodCacher::Base

  attr_accessor :id

  caches_method :foo

  def foo
    Dummy.function
  end
end

# for testing when the :obj_key option is undefined and the default id method is missing
class SixthClass
  include  MethodCacher::Base

  caches_method :foo

  def foo
    Dummy.function
  end
end

# for testing adding methods to be cached using separate caches_method calls
class SeventhClass
  include MethodCacher::Base

  def id
    object_id
  end

  caches_method :foo1, singleton: :bar1
  caches_method :foo2, singleton: :bar2
  caches_method :foo3, :foo4, singleton: [:bar3, :bar4]

  # test instance methods.
  def foo1
    Dummy.function
  end

  def foo2
    Dummy.function
  end

  def foo3
    Dummy.function
  end

  def foo4
    Dummy.function
  end

  def foo5
    Dummy.function
  end

  def foo6
    Dummy.function
  end

  def foo7
    Dummy.function
  end

  def foo8
    Dummy.function
  end

  class <<self
    # test singleton (i.e. class) methods.
    def bar1
      Dummy.function
    end

    def bar2
      Dummy.function
    end

    def bar3
      Dummy.function
    end

    def bar4
      Dummy.function
    end

    def bar5
      Dummy.function
    end

    def bar6
      Dummy.function
    end

    def bar7
      Dummy.function
    end

    def bar8
      Dummy.function
    end
  end

  caches_method :foo5, singleton: :bar5
  caches_method :foo6, singleton: :bar6
  caches_method :foo7, :foo8, singleton: [:bar7, :bar8]
end

# for testing caching of private and protected instance methods
class EighthClass
  include MethodCacher::Base

  def id
    object_id
  end

  caches_method :foo1, :foo3

  protected
  def foo1
    Dummy.function
  end

  def foo2
    Dummy.function
  end

  private
  def foo3
    Dummy.function
  end

  def foo4
    Dummy.function
  end

  #caches_method :foo2, :foo4
end