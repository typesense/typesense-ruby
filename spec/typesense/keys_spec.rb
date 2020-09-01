# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Keys do
  subject(:keys) { typesense.keys }

  include_context 'with Typesense configuration'

  describe '#create' do
    it 'creates a key and returns it' do
      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/keys', typesense.configuration.nodes[0]))
        .with(body: JSON.dump('description' => 'Search-only key.', 'actions' => ['documents:search'], 'collections' => ['*']),
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump({}), headers: { 'Content-Type': 'application/json' })

      result = keys.create('description' => 'Search-only key.', 'actions' => ['documents:search'], 'collections' => ['*'])

      expect(result).to eq({})
    end
  end

  describe '#retrieve' do
    it 'returns all keys' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/keys', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200,
                   body: JSON.dump([{ 'description' => 'Search-only key.', 'actions' => ['documents:search'], 'collections' => ['*'] }]),
                   headers: {
                     'Content-Type': 'application/json'
                   })

      result = keys.retrieve

      expect(result).to eq([{ 'description' => 'Search-only key.', 'actions' => ['documents:search'], 'collections' => ['*'] }])
    end
  end

  describe '#generate_scoped_search_key' do
    it 'returns a scoped search key' do
      # The following keys were generated and verified to work with an actual Typesense server
      # We're only verifying that the algorithm works as expected client-side
      search_key = 'RN23GFr1s6jQ9kgSNg2O7fYcAUXU7127'
      scoped_search_key = 'SC9sT0hncHFwTHNFc3U3d3psRDZBUGNXQUViQUdDNmRHSmJFQnNnczJ4VT1STjIzeyJmaWx0ZXJfYnkiOiJjb21wYW55X2lkOjEyNCJ9'
      result = keys.generate_scoped_search_key(search_key, filter_by: 'company_id:124')

      expect(result).to eq(scoped_search_key)
    end
  end

  describe '#[]' do
    it 'returns an key object' do
      result = keys['123']

      expect(result).to be_a_kind_of(Typesense::Key)
      expect(result.instance_variable_get(:@id)).to eq('123')
    end
  end
end
