# frozen_string_literal: true

require_relative '../spec_helper'

shared_context 'with Typesense configuration', shared_context: :metadata do
  let(:typesense) do
    Typesense::Client.new(
      api_key: 'abcd',
      nodes: [
        {
          host: 'node0',
          port: 8108,
          protocol: 'http'
        },
        {
          host: 'node1',
          port: 8108,
          protocol: 'http'
        },
        {
          host: 'node2',
          port: 8108,
          protocol: 'http'
        }
      ],
      connection_timeout_seconds: 10,
      retry_interval_seconds: 0.01,
      log_level: Logger::ERROR
    )
  end
end
