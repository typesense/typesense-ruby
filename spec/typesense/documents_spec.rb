require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Documents do
  include_context 'Typesense configuration'

  subject { typesense.collections['companies'].documents }

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

      result = subject.create(document)

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

      result = subject.export

      expect(result).to eq(%W(#{JSON.dump(document)} #{JSON.dump(document)}))
    end
  end

  describe '#search' do
    let(:search_parameters) do
      {
          'q'        => 'Stark',
          'query_by' => 'company_name'
      }
    end

    let(:stubbed_search_result) do
      {
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
    end

    it 'search the documents in a collection' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/search')).
          with(headers: {
              'X-Typesense-Api-Key' => typesense.configuration.master_node[:api_key]
          },
               query:   search_parameters).
          to_return(status: 200, body: JSON.dump(stubbed_search_result), headers: { 'Content-Type': 'application/json' })

      result = subject.search(search_parameters)

      expect(result).to eq(stubbed_search_result)
    end
  end

  describe '#[]' do
    it 'creates a document object and returns it' do
      result = subject['124']

      expect(result).to be_a_kind_of(Typesense::Document)
      expect(result.instance_variable_get(:@document_id)).to eq('124')
    end
  end
end

