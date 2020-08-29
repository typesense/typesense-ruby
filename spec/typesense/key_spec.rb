# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Key do
  subject(:key) { typesense.keys['123'] }

  include_context 'with Typesense configuration'

  describe '#retrieve' do
    it 'returns the specified key' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/keys/123', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump({}), headers: { 'Content-Type': 'application/json' })

      result = key.retrieve

      expect(result).to eq({})
    end
  end

  describe '#delete' do
    it 'deletes the specified key' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/keys/123', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump({}), headers: { 'Content-Type': 'application/json' })

      result = key.delete

      expect(result).to eq({})
    end
  end
end
