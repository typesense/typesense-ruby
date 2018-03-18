# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_group 'lib', 'lib'

  add_filter 'spec'
end

require 'bundler/setup'
require 'webmock/rspec'
require 'typesense'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.expose_dsl_globally = true

  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to
  # set it on RSpec 3.
  #
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
