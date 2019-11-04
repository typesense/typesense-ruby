# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'typesense/version'

Gem::Specification.new do |spec|
  spec.name          = 'typesense'
  spec.version       = Typesense::VERSION
  spec.authors       = ['Typesense, Inc.']
  spec.email         = ['contact@typesense.org']

  spec.summary       = 'Ruby Library for Typesense'
  spec.description   = 'Typesense is an open source search engine for building a delightful search experience.'
  spec.homepage      = 'https://typesense.org'
  spec.license       = 'Apache-2.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print', '~> 1.8'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'codecov', '~> 0.1'
  spec.add_development_dependency 'pry-byebug', '~> 3.7'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rspec-legacy_formatters', '~> 1.0' # For codecov formatter
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4'
  spec.add_development_dependency 'rubocop', '~> 0.76'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.36'
  spec.add_development_dependency 'simplecov', '~> 0.17'
  spec.add_development_dependency 'webmock', '~> 3.7'

  spec.add_dependency 'httparty', '~> 0.17'
end
