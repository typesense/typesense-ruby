require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Documents do
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

  let(:document) do
    {
        'id'            => '124',
        'company_name'  => 'Stark Industries',
        'num_employees' => 5215,
        'country'       => 'USA'
    }
  end

  describe '#create' do
    it 'creates creates/indexes a document and returns it' do
      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents')).
          with(body:    document,
               headers: {
                   'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key],
                   'Content-Type'        => 'application/json'
               }).
          to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

      result = Typesense::Documents.new(typesense.configuration, 'companies').create(document)

      expect(result).to eq(document)
    end
  end

  describe '#retrieve' do
    it 'returns the specified document' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/124')).
          with(headers: {
              'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key]
          }).
          to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

      result = Typesense::Documents.new(typesense.configuration, 'companies', '124').retrieve

      expect(result).to eq(document)
    end
  end

  describe '#delete' do
    it 'deletes the specified document' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/124')).
          with(headers: {
              'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key]
          }).
          to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

      result = Typesense::Documents.new(typesense.configuration, 'companies', '124').delete

      expect(result).to eq(document)
    end
  end

  describe '#export' do
    it 'exports all documents in a collection as an array' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/export')).
          with(headers: {
              'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key]
          }).
          to_return(status: 200, body: "#{JSON.dump(document)}\n#{JSON.dump(document)}")

      result = Typesense::Documents.new(typesense.configuration, 'companies').export

      expect(result).to eq(%W(#{JSON.dump(document)} #{JSON.dump(document)}))
    end
  end

  describe '#search' do
    it 'search the documents in a collection' do
      search_parameters     = {
          'q'        => 'Stark',
          'query_by' => 'company_name'
      }
      stubbed_search_result = {
          'facet_counts'   => [],
          'found'          => 0,
          'search_time_ms' => 0,
          'page'           => 0,
          'hits'           => [
              {
                  '_highlight' => {
                      'company_name' => '<mark>Stark</mark> Industries'
                  },
                  'document'   => {
                      'id'            => '124',
                      'company_name'  => 'Stark Industries',
                      'num_employees' => 5215,
                      'country'       => 'USA'
                  }
              }
          ]
      }
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/search')).
          with(headers: {
              'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key]
          },
               query:   search_parameters).
          to_return(status: 200, body: JSON.dump(stubbed_search_result), headers: { 'Content-Type': 'application/json' })

      result = Typesense::Documents.new(typesense.configuration, 'companies').search(search_parameters)

      expect(result).to eq(stubbed_search_result)
    end
  end

end

