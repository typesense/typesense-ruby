# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Aliases do
  include_context 'with Typesense configuration'

  subject(:aliases) { typesense.aliases }

  describe '#upsert' do
    it 'upserts an alias and returns it' do
      stub_request(:put, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/aliases/books', typesense.configuration.nodes[0]))
        .with(body: JSON.dump('collection_name' => 'books_january'),
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump('collection_name' => 'books_january'), headers: { 'Content-Type': 'application/json' })

      result = aliases.upsert('books', 'collection_name' => 'books_january')

      expect(result).to eq('collection_name' => 'books_january')
    end
  end

  describe '#retrieve' do
    it 'returns all aliases' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/aliases', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200,
                   body: JSON.dump(['collection_name' => 'books_january']),
                   headers: {
                     'Content-Type': 'application/json'
                   })

      result = aliases.retrieve

      expect(result).to eq(['collection_name' => 'books_january'])
    end
  end

  describe '#[]' do
    it 'returns an alias object' do
      result = aliases['books']

      expect(result).to be_a_kind_of(Typesense::Alias)
      expect(result.instance_variable_get(:@name)).to eq('books')
    end
  end
end
