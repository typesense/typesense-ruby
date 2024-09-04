# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Alias do
  subject(:client) { typesense }

  let(:books_alias) { typesense.aliases['books'] }

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

    it 'returns the specified alias with URI encoded name' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/aliases/abc123%3F%3D%2B-_!%40%23%24%25%5E%26*()~%20%2F', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump('collection_name' => 'books_january'), headers: { 'Content-Type': 'application/json' })

      result = client.aliases["abc123?=+-_!@\#$%^&*()~ /"].retrieve

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
