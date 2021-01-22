# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Stats do
  subject(:stats) { typesense.stats }

  include_context 'with Typesense configuration'

  describe '#retrieve' do
    it 'retrieves endpoint stats' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/stats.json', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: '{}', headers: { 'Content-Type': 'application/json' })

      result = stats.retrieve

      expect(result).to eq({})
    end
  end
end
