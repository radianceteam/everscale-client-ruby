# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ever_sdk_client/version'

Gem::Specification.new do |gem|
  gem.name = "ever_sdk_client"
  gem.authors = ["Alex Maslakov"]
  gem.summary = "Everscale SDK client library, in Ruby and for Ruby"
  gem.description = "Everscale SDK client library written in Ruby and to be used as a Ruby gem, for tonlabs.io"
  gem.email = "alex@serendipia.email"
  gem.license = "MIT"
  gem.homepage = "https://github.com/radianceteam/everscale-client-ruby"

  gem.version = EverSdk::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.required_ruby_version = ">= 3.0"
  gem.extra_rdoc_files = ["README.md", "LICENSE"]

  gem.files = Dir[
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
    "lib/**/*.rb",
    "lib/**/*.rake",
    "Gemfile",
    "Rakefile"
  ]

  gem.add_dependency "ffi", "~> 1.13"
  gem.add_dependency "concurrent-ruby", "~> 1.1.7"

  gem.add_development_dependency "rspec", "~> 3.4"
  gem.add_development_dependency "bundler", "~> 2.1"
  gem.add_development_dependency "rake", "~> 13.0"
end
