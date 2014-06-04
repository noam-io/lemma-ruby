# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'noam_lemma/version'

Gem::Specification.new do |spec|
  spec.name          = "noam_lemma"
  spec.version       = NoamLemma::VERSION
  spec.authors       = ["John Van Enk"]
  spec.email         = ["vanenkj@gmail.com"]
  spec.description   = %q{A lemma factory for the Noam pub-sub system.}
  spec.summary       = %q{A lemma factory for the Noam pub-sub system.}
  spec.homepage      = "https://github.com/noam-io/lemma-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "require_all"
  spec.add_development_dependency "bundler", "~>  1.3"
  spec.add_development_dependency "rake",    "~> 10.3"
  spec.add_development_dependency "rspec",   "~>  2.14"
  spec.add_development_dependency "mocha",   "~>  1.1"
end
