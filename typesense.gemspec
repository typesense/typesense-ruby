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

  spec.required_ruby_version = '>= 3.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'base64', '~> 0.2'
  spec.add_dependency 'faraday', '~> 2.8'
  spec.add_dependency 'faraday-net_http_persistent', '~> 2.0'
  spec.add_dependency 'json', '~> 2.9'
  spec.add_dependency 'net-http-persistent', '~> 4.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
