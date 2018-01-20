
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "typesense/version"

Gem::Specification.new do |spec|
  spec.name          = "typesense"
  spec.version       = Typesense::VERSION
  spec.authors       = ["Wreally Studios"]
  spec.email         = ["contact@wreally.com"]

  spec.summary       = %q{Ruby Library for Typesense}
  spec.description   = %q{Typesense is an open source search engine for building a delightful search experience.}
  spec.homepage      = "https://github.com/wreally/typesense-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.2"
  spec.add_development_dependency "pry-byebug", "~> 3.5"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.3"

  spec.add_dependency "httparty", "~> 0.15"
end
