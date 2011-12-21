# Method Cacher

Wraps specified methods with a mechanism that caches the return values.

Features:
* Can cache both instance and singleton (i.e. class) methods.
* Differentiates among calls to a method with different arguments.
* Generates methods to provide access the original uncached methods.
* Generates methods to clear the cache of each cached method.
* To specify methods to be cached, just call `caches_method :method1, :method2 ...` before or after the actual declaration of 'method1' and 'method2'.
