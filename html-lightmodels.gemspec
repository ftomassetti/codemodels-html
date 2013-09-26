# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'html-lightmodels/version'

Gem::Specification.new do |spec|
  spec.platform      = 'java'
  spec.name          = "html-lightmodels"
  spec.version       = LightModels::Html::VERSION
  spec.authors       = ["Federico Tomassetti"]
  spec.email         = ["f.tomassetti@gmail.com"]
  spec.description   = %q{LightModels for HTML}
  spec.summary       = %q{LightModels for HTML}
  spec.homepage      = ""
  spec.license       = "Apache License 2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "lightmodels"
  spec.add_dependency "js-lightmodels"
  spec.add_dependency "rgen"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
