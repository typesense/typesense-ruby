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

  # rubocop:disable Gemspec/RequiredRubyVersion
  spec.required_ruby_version = '>= 2.4'
  # rubocop:enable Gemspec/RequiredRubyVersion

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'oj', '~> 3.16'
  spec.add_dependency 'typhoeus', '~> 1.4'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
