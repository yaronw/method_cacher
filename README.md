# Method Cacher

Wraps specified methods with a mechanism that caches the return values.

__Features:__

+ Can cache both instance and singleton (i.e. class) methods.
+ Differentiates among calls to a method with different arguments.
+ Generates methods to provide access the original uncached methods.
+ Generates methods to clear the cache of each cached method.
+ To specify methods to be cached, just call `caches_method :method1, :method2 ...` before or after the actual definition of `method1` and `method2`.
+ When used with Rails, it automatically uses the cache store configured in Rails.

## Installation

Add the `method_cacher` gem your Gemfile and run the `bundle` command to install it.

```ruby
gem 'method_cacher'
```

__Requires Ruby 1.9.2 or later.__

## Configuration

...

## Usage

Include the method cacher module in the class whose methods you wish to cache.

```ruby
include MethodCacher::Base
```

The module is included automatically for ActiveRecord when used in Rails.

Call `cache_method` from within the class definition, listing the names of the methods that are to be cached.

```ruby
cache_method :instance_method1, :instance_method1, singleton: [:singleton_method1, :singleton_method2]
```

Instance methods are specified as symbol arguments. Singleton methods are specified an array of symbols
passed through the `:singleton` option.

`cache_method` can take any number of instance or singleton methods at once.

Subsequent calls to `cache_method` are possible in order to specify additional methods to be cached.

`cache_method` can be called _before_ or _after_ the specified methods are defined.

```ruby
cache_method :foo # this works
def foo
...
end

def bar
...
end
cache_method :bar # this also works
```