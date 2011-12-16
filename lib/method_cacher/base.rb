require 'active_support/concern'
require 'active_support/core_ext'
require 'set'

module MethodCacher
  class <<self
    mattr_accessor :caching_strategy

    self.caching_strategy = Rails.cache if defined? Rails
  end

  module Base
    extend ActiveSupport::Concern

       # default object key proc
    OBJECT_KEY_PROC_DEFAULT = lambda { |obj| obj.id }

    module ClassMethods

      attr_accessor :methods_to_be_cached, :cached_methods, :obj_key
      attr_accessor :singleton_methods_to_be_cached, :singleton_cached_methods

      def caches_method(*method_names)
        initialize_variables

        # process parameters
        options = method_names.extract_options!

        self.obj_key = options[:obj_key] || self.obj_key # if obj_key is given in the option, replace it with what's given
        self.methods_to_be_cached += method_names
        self.singleton_methods_to_be_cached += [options[:singleton]].flatten

        # Cache all currently defined instance methods that are given in the parameters .
        self.methods_to_be_cached.clone.each do |method_name|
          add_cached_method(method_name) if (private_instance_methods + protected_instance_methods + public_instance_methods).include?(method_name)
        end

        # Cache all currently defined singleton methods given in the parameters.
        self.singleton_methods_to_be_cached.clone.each do |method_name|
          singleton_add_cached_method(method_name) if singleton_methods.include?(method_name)
        end
      end

      # This callback adds caching to the methods that were not defined yet when caches_method was called.
      def method_added(method_name)
        super
        initialize_variables
        add_cached_method(method_name) if self.methods_to_be_cached.include?(method_name)
      end

      # Same as method_added but for singleton methods.
      def singleton_method_added(method_name)
        super
        initialize_variables
        singleton_add_cached_method(method_name) if self.singleton_methods_to_be_cached.include?(method_name)
      end

      private

      # Initialize class instance variables for instance method caching.
      def initialize_variables
        self.obj_key ||= OBJECT_KEY_PROC_DEFAULT # identifies the object of this class, defaults to the object's id if defined

        #if !self.obj_key
        #  if method_defined? :id
        #     self.obj_key = lambda { |obj| obj.id }
        #  else
        #    raise Exception.new "There's no object key defined.  Please supply an id instance method, or pass an proc to the :obj_key option of caches_method."
        #  end
        #end

        self.methods_to_be_cached ||= Set.new  # stores the names of the methods designated to be cached
        self.cached_methods ||= Set.new # stores the methods that are cached

        # initialize class instance variables for singleton method caching
        self.singleton_methods_to_be_cached ||= Set.new  # stores the names of the methods designated to be cached
        self.singleton_cached_methods ||= Set.new # stores the methods that are cached
      end

      # Creates the key used to cache a singleton method of the object.
      def singleton_cached_method_key(method_name, *args)
        [self.name, method_name, *args]
      end

      # Adds code to the class to cache the given instance method.
      def add_cached_method(method_name)
        self.methods_to_be_cached.delete(method_name)
        self.cached_methods <<= method_name
        class_eval <<-END_EVAL, __FILE__, __LINE__ + 1
          alias :uncached_#{method_name} :#{method_name}

          def #{method_name}(*args)
            key = cached_method_key(:#{method_name}, *args)
            key.nil? ? uncached_#{method_name}(*args) : MethodCacher.caching_strategy.fetch(key) { uncached_#{method_name}(*args) }  # cache only for non-nil keys
          end

          def clear_cache_for_#{method_name}(*args)
            MethodCacher.caching_strategy.delete(cached_method_key(:#{method_name}, *args))
          end
        END_EVAL
      end

      # Adds code to the class to cache the given singleton method.
      def singleton_add_cached_method(method_name)
        self.singleton_methods_to_be_cached.delete(method_name)
        self.singleton_cached_methods <<= method_name
        class_eval <<-END_EVAL, __FILE__, __LINE__ + 1
          class <<self
            alias :uncached_#{method_name} :#{method_name}

            def #{method_name}(*args)
              MethodCacher.caching_strategy.fetch(singleton_cached_method_key(:#{method_name}, *args)) { uncached_#{method_name}(*args) }
            end

            def clear_cache_for_#{method_name}(*args)
              MethodCacher.caching_strategy.delete(singleton_cached_method_key(:#{method_name}, *args))
            end
          end
        END_EVAL
      end

    end

    module InstanceMethods

      # A helper that clears the cache for all the cached methods of this object that are argument-less.
      def clear_method_cache
        self.class.cached_methods.each { |method_name| MethodCacher.caching_strategy.delete(cached_method_key(method_name)) }
      end

      private

      # Creates the key used to cache a method of the object.
      def cached_method_key(method_name, *args)
        obj_key = self.class.obj_key.call(self)
        [self.class.name, obj_key, method_name, *args]
      end
    end
  end
end
