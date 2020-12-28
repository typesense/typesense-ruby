# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Operations do
  subject(:operations) { typesense.operations }

  include_context 'with Typesense configuration'

  describe '#perform' do
    it 'performs the specificied operation' do
      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/operations/snapshot', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              },
              query: {
                snapshot_path: '/tmp/dbsnap'
              })
        .to_return(status: 200, body: '{}', headers: { 'Content-Type': 'application/json' })

      result = operations.perform(:snapshot, { snapshot_path: '/tmp/dbsnap' })

      expect(result).to eq({})
    end
  end
end
