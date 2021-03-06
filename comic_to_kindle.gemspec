# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'comic_to_kindle/version'

Gem::Specification.new do |spec|
  spec.name          = "comic_to_kindle"
  spec.version       = ComicToKindle::VERSION
  spec.authors       = ["Devin Clark"]
  spec.email         = ["notdevinclark@gmail.com"]

  spec.summary       = %q{CLI for resizing .cbz and .cbr comic archives to fit on the Kindle Paperwhite}
  spec.description   = %q{CLI for resizing .cbz and .cbr comic archives to fit on the Kindle Paperwhite}
  spec.homepage      = "https://github.com/notdevinclark/comic-to-kindle-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
