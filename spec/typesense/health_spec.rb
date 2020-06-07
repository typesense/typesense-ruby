# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Health do
  include_context 'with Typesense configuration'

  describe '#retrieve' do
    it 'retrieves health information' do
      health_info = {
        'ok' => true
      }
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/health', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump(health_info), headers: { 'Content-Type': 'application/json' })

      result = typesense.health.retrieve

      expect(result).to eq(health_info)
    end
  end
end
