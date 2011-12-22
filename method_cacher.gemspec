# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)  # $: is the load path
require 'method_cacher/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Yaron Walfish"]
  gem.email         = ["yaronw@yaronw.com"]
  gem.description   = %q{Easily cache instance and class methods of ActiveRecord or any object.}
  gem.summary       = %q{Wraps specified instance and singleton methods with the Rails caching mechanism.}
  gem.homepage      = "https://github.com/yaronw/method_cacher"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "method_cacher"
  gem.require_paths = ["lib"]
  gem.version       = MethodCacher::VERSION

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'supermodel'
  gem.add_development_dependency 'activesupport'
  gem.add_development_dependency 'ruby-debug19'
end
