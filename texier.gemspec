# -*- encoding: utf-8 -*-
require File.expand_path('../lib/texier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Adam Ciganek", "Josef Šimánek"]
  gem.email         = ["adam.ciganek@gmail.com", "retro@ballgag.cz"]
  gem.description   = %q{Texy for Ruby}
  gem.summary       = %q{Texy for Ruby}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "texier"
  gem.require_paths = ["lib"]
  gem.version       = Texier::VERSION

  gem.add_development_dependency "rake", '>= 0.9.2'
  gem.add_development_dependency "mocha"
end
