# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'craigslist/version'

Gem::Specification.new do |spec|
  spec.name          = "craigslist"
  spec.version       = Craigslist::VERSION
  spec.authors       = ["Christopher Rankin"]
  spec.email         = ["rankin.devon@gmail.com"]
  spec.description   = %q{Gem to interface with and scrape Craigslist}
  spec.summary       = %q{Scrape different sections of craigslist with a smple interface}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

end
