# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Synonym do
  subject(:synonym) { typesense.collections['companies'].synonyms['synonym-set-1'] }

  include_context 'with Typesense configuration'

  let(:synonym_data) do
    {
      'id' => 'synonym-set-1',
      'synonyms' => %w[
        lex
        luthor
        businessman
      ]
    }
  end

  describe '#retrieve' do
    it 'returns the specified synonym' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/synonyms/synonym-set-1', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type': 'application/json'
              })
        .to_return(status: 200, body: JSON.dump(synonym_data), headers: { 'Content-Type': 'application/json' })

      result = synonym.retrieve

      expect(result).to eq(synonym_data)
    end
  end

  describe '#delete' do
    it 'deletes the specified synonym' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/synonyms/synonym-set-1', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump('id' => 'synonym-set-1'), headers: { 'Content-Type': 'application/json' })

      result = synonym.delete

      expect(result).to eq('id' => 'synonym-set-1')
    end
  end
end
