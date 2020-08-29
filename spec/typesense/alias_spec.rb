# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Alias do
  subject(:books_alias) { typesense.aliases['books'] }

  include_context 'with Typesense configuration'

  describe '#retrieve' do
    it 'returns the specified alias' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/aliases/books', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump('collection_name' => 'books_january'), headers: { 'Content-Type': 'application/json' })

      result = books_alias.retrieve

      expect(result).to eq('collection_name' => 'books_january')
    end
  end

  describe '#delete' do
    it 'deletes the specified collection' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/aliases/books', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump('collection_name' => 'books_january'), headers: { 'Content-Type': 'application/json' })

      result = books_alias.delete

      expect(result).to eq('collection_name' => 'books_january')
    end
  end
end
