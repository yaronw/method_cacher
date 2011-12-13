# -*- encoding: utf-8 -*-
require File.expand_path('../lib/method_cacher/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yaron Walfish"]
  gem.email         = ["yaronw@yaronw.com"]
  gem.description   = %q{Caches Instance and Singleton Methods}
  gem.summary       = %q{Wraps specified instance and singleton methods with the Rails caching mechanism.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "method_cacher"
  gem.require_paths = ["lib"]
  gem.version       = MethodCacher::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "supermodel"
end
