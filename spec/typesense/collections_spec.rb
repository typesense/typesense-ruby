require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Collections do
  include_context 'Typesense configuration'

  subject { Typesense::Collections }

  let(:company_schema) do
    {
        'name'                => 'companies',
        'num_documents'       => 0,
        'fields'              => [
            {
                'name'  => 'company_name',
                'type'  => 'string',
                'facet' => false
            },
            {
                'name'  => 'num_employees',
                'type'  => 'int32',
                'facet' => false
            },
            {
                'name'  => 'country',
                'type'  => 'string',
                'facet' => true
            }
        ],
        'token_ranking_field' => 'num_employees'
    }
  end

  describe '.create' do
    it 'creates a collection and returns it' do
      # since num_documents is a read-only attribute
      schema_for_creation = company_schema.select { |key, value| key != 'num_documents' }

      stub_request(:post, Typesense::ApiCall.send(:uri_for, '/collections')).
          with(body:    schema_for_creation,
               headers: {
                   'X-Typesense-Api-Key' => Typesense.configuration.api_key,
                   'Content-Type'        => 'application/json'
               }).
          to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = Typesense::Collections.create(schema_for_creation)

      expect(result).to eq(company_schema)
    end
  end

  describe '.get' do
    it 'returns the specified collection' do
      stub_request(:get, Typesense::ApiCall.send(:uri_for, '/collections/companies')).
          with(headers: {
                   'X-Typesense-Api-Key' => Typesense.configuration.api_key
               }).
          to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = Typesense::Collections.get('companies')

      expect(result).to eq(company_schema)
    end
  end

  describe '.get_all' do
    it 'returns all collections'
  end

  describe '.delete' do
    it 'deletes the specified collection'
  end
end

