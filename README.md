# Method Cacher

Wraps specified methods with a mechanism that caches the return values.

__Features:__

+ Can cache both instance and singleton (i.e. class) methods.
+ Differentiates among calls to a method with different arguments.
+ Generates methods to provide access the original uncached methods.
+ Generates methods to clear the cache of each cached method.
+ To specify methods to be cached, just call `caches_method :foo, :bar ...` before or after the actual definition of `foo` and `bar`.
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
cache_method :instance_foo, :instance_bar, singleton: [:singleton_foo, :singleton_bar], obj_key: proc { |obj| obj.obj_key }
```

Instance methods are specified as symbol arguments.

__Options:__

+ :singleton - Singleton methods to be cached are specified in an array of symbols passed through this option.
+ :obj\_key - A _proc_ that accepts the cached object as a single parameter.  This _proc_ should return a value identifying this object.
    If this option is not specified, the object key defaults to the value returned by a method named _id_, which is convenient for usage
    with ActiveRecord objects.

`cache_method` can take any number of instance or singleton methods at once.

Subsequent calls to `cache_method` are possible in order to specify additional methods to be cached.
Specifying :obj\_id multiple times results in the last one being used for the class.

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

`cache_method` replaces each specified method with a cached version.

The cached versions take the same arguments as the originals, with different arguments caching separately.

Each of the original methods is made accessible through the alias `uncached_` followed by the method's name.
E.g. if the method is `foo`, the original is aliased as `uncached_foo`.

`cache_method` also adds methods to clear the cache of each cached method.
These methods are named `clear_cache_for_` followed by the cached method's name.
The clear cache methods take identical arguments as their respective original and cached methods, and only
clear the cache for the given set of arguments.

So for example, issuing `clear_cache_for_foo('a')`, would clear the cache for a call to `foo('a')`
but not to `foo('b')`.