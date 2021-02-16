# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::MultiSearch do
  include_context 'with Typesense configuration'

  describe '#perform' do
    it 'does a multi-search request' do
      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/multi_search', typesense.configuration.nodes[0]))
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'X-Typesense-Api-Key' => typesense.configuration.api_key
          },
          query: hash_including({ param: 'a' }),
          body: JSON.dump({ searches: [] })
        ).to_return(status: 200, body: '{}', headers: { 'Content-Type': 'application/json' })

      result = typesense.multi_search.perform({ searches: [] }, { param: 'a' })

      expect(result).to eq({})
    end
  end
end
