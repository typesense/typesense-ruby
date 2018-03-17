require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Collections do
  include_context 'Typesense configuration'

  subject { typesense.collections }

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

  describe '#create' do
    it 'creates a collection and returns it' do
      # since num_documents is a read-only attribute
      schema_for_creation = company_schema.select { |key, value| key != 'num_documents' }

      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections')).
          with(body:    schema_for_creation,
               headers: {
                   'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key],
                   'Content-Type'        => 'application/json'
               }).
          to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = subject.create(schema_for_creation)

      expect(result).to eq(company_schema)
    end
  end

  describe '#retrieve_all' do
    it 'returns all collections' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections')).
          with(headers: {
              'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key]
          }).
          to_return(status: 200, body: JSON.dump([company_schema]), headers: { 'Content-Type': 'application/json' })

      result = subject.retrieve_all

      expect(result).to eq([company_schema])
    end
  end

  describe '#[]' do
    it 'returns a collection object' do
      result = subject['companies']

      expect(result).to be_a_kind_of(Typesense::Collection)
      expect(result.instance_variable_get(:@name)).to eq('companies')
    end
  end
end

