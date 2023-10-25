# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Collections do
  subject(:collections) { typesense.collections }

  include_context 'with Typesense configuration'

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

  describe '#create' do
    it 'creates a collection and returns it' do
      # since num_documents is a read-only attribute
      schema_for_creation = company_schema.reject { |key, _| key == 'num_documents' }

      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections', typesense.configuration.nodes[0]))
        .with(body: schema_for_creation,
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = collections.create(schema_for_creation)

      expect(result).to eq(company_schema)
    end
  end

  describe '#retrieve' do
    it 'returns all collections' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump([company_schema]), headers: { 'Content-Type': 'application/json' })

      result = collections.retrieve

      expect(result).to eq([company_schema])
    end
  end

  describe '#[]' do
    it 'returns a collection object' do
      result = collections['companies']

      expect(result).to be_a(Typesense::Collection)
      expect(result.instance_variable_get(:@name)).to eq('companies')
    end
  end
end
