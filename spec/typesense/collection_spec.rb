# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Collection do
  include_context 'with Typesense configuration'

  subject(:companies_collection) { typesense.collections['companies'] }

  let(:company_schema) do
    {
      'name' => 'companies',
      'num_documents' => 0,
      'fields' => [
        {
          'name' => 'company_name',
          'type' => 'string',
          'facet' => false
        },
        {
          'name' => 'num_employees',
          'type' => 'int32',
          'facet' => false
        },
        {
          'name' => 'country',
          'type' => 'string',
          'facet' => true
        }
      ],
      'token_ranking_field' => 'num_employees'
    }
  end

  describe '#retrieve' do
    it 'returns the specified collection' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies', 0))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = companies_collection.retrieve

      expect(result).to eq(company_schema)
    end
  end

  describe '#delete' do
    it 'deletes the specified collection' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies', 0))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = companies_collection.delete

      expect(result).to eq(company_schema)
    end
  end

  describe '#documents' do
    it 'creates a documents object and returns it' do
      result = companies_collection.documents

      expect(result).to be_a_kind_of(Typesense::Documents)
    end
  end
end
