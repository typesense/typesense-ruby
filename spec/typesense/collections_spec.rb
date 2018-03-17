require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Collections do
  include_context 'Typesense configuration'

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

      result = Typesense::Collections.new(typesense.configuration).create(schema_for_creation)

      expect(result).to eq(company_schema)
    end

    it 'throws an error if a collection name is set' do
      expect {
        Typesense::Collections.new(typesense.configuration, 'companies').create(company_schema)
      }.to raise_exception Typesense::Error::NoMethodError
    end
  end

  describe '#retrieve' do
    it 'returns the specified collection' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies')).
          with(headers: {
              'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key]
          }).
          to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = Typesense::Collections.new(typesense.configuration, 'companies').retrieve

      expect(result).to eq(company_schema)
    end
  end

  describe '#delete' do
    it 'deletes the specified collection' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies')).
          with(headers: {
              'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key]
          }).
          to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = Typesense::Collections.new(typesense.configuration, 'companies').delete

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

      result = Typesense::Collections.new(typesense.configuration).retrieve_all

      expect(result).to eq([company_schema])
    end

    it 'throws an error if a collection name is set' do
      expect {
        Typesense::Collections.new(typesense.configuration, 'companies').retrieve_all
      }.to raise_exception Typesense::Error::NoMethodError
    end
  end

  describe '#documents' do
    context 'when no arguments are passed' do
      it 'creates a documents object and returns it' do
        result = typesense.collections('companies').documents

        expect(result).to be_a_kind_of(Typesense::Documents)
        expect(result.instance_variable_get(:@document_id)).to be_nil
      end
    end

    context 'when a document id is passed' do
      it 'creates a documents object and returns it' do
        result = typesense.collections('companies').documents('124')

        expect(result).to be_a_kind_of(Typesense::Documents)
        expect(result.instance_variable_get(:@document_id)).to eq('124')
      end
    end

    it 'throws an error if a collection name is not set' do
      expect {
        Typesense::Collections.new(typesense.configuration, nil).documents
      }.to raise_exception Typesense::Error::NoMethodError
    end
  end


end

