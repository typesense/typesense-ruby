# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_group 'lib', 'lib'

  add_filter 'spec'
end

require 'bundler/setup'
require 'webmock/rspec'
require 'typesense'
require 'faraday'

WebMock.disable_net_connect!(allow_localhost: true)

def typesense_healthy?(host = 'localhost', port = 8108)
  conn = Faraday.new("http://#{host}:#{port}")
  response = conn.get('/health')
  response.status == 200 && response.body.include?('ok')
rescue StandardError
  false
end

def start_typesense_if_needed
  if typesense_healthy?
    puts '✅ Typesense is already running and healthy, ready for use in integration tests'
    return false
  end

  # Check if Docker is running
  unless system('docker info > /dev/null 2>&1')
    raise 'Docker daemon is not running. Please start Docker and try again.'
  end

  puts 'Starting Typesense with docker-compose...'
  unless system('docker-compose up -d')
    raise 'Failed to start docker-compose'
  end

  # Wait for Typesense to be ready
  print 'Waiting for Typesense to start'
  20.times do
    break if typesense_healthy?

    print '.'
    sleep 1
  end
  puts

  unless typesense_healthy?
    raise 'Failed to start Typesense - health endpoint did not return OK'
  end

  puts 'Typesense is ready!'
  $typesense_started_by_tests = true
  true
end

def stop_typesense_if_started
  unless $typesense_started_by_tests
    puts "\e[33m\nTest suite did not shut down Typesense automatically, because it was already running when tests started\e[0m"
    return
  end

  puts 'Stopping Typesense...'
  system('docker-compose down')
end

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

  config.before(:suite) do
    $typesense_started_by_tests = start_typesense_if_needed
    WebMock.disable_net_connect!
  end

  config.after(:suite) do
    stop_typesense_if_started
  end
end
