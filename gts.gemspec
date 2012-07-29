# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gts/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Milan Novota"]
  gem.email         = ["milan.novota@gmail.com"]
  gem.description   = ["GPS Tracking Server"]
  gem.summary       = ["GPS Tracking Server"]
  gem.homepage      = "http://github.com/milann/gts"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "gts"
  gem.require_paths = ["lib"]
  gem.version       = Gts::VERSION

  gem.add_dependency "eventmachine"
  gem.add_dependency "json"
  gem.add_dependency "redis"
  gem.add_development_dependency "rspec"

end
