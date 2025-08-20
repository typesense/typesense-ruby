# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Synonyms do
  subject(:companies_synonyms) { typesense.collections['companies'].synonyms }

  include_context 'with Typesense configuration'

  let(:synonym) do
    {
      'id' => 'synonym-set-1',
      'synonyms' => %w[
        lex
        luthor
        businessman
      ]
    }
  end

  before do
    skip('Synonyms is deprecated in Typesense v30+, use SynonymSets instead') if typesense_v30_or_above?
  end

  describe '#upsert' do
    it 'creates an synonym rule and returns it' do
      stub_request(:put, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/synonyms/synonym-set-1', typesense.configuration.nodes[0]))
        .with(body: synonym,
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 201, body: JSON.dump(synonym), headers: { 'Content-Type': 'application/json' })

      result = companies_synonyms.upsert(synonym['id'], synonym)

      expect(result).to eq(synonym)
    end
  end

  describe '#retrieve' do
    it 'retrieves all synonyms' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/synonyms', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 201, body: JSON.dump([synonym]), headers: { 'Content-Type': 'application/json' })

      result = companies_synonyms.retrieve

      expect(result).to eq([synonym])
    end
  end

  describe '#[]' do
    it 'creates an synonym object and returns it' do
      result = companies_synonyms['synonym-set-1']

      expect(result).to be_a(Typesense::Synonym)
      expect(result.instance_variable_get(:@synonym_id)).to eq('synonym-set-1')
    end
  end
end
