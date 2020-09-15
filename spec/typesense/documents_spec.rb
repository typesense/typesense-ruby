# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Documents do
  subject(:companies_documents) { typesense.collections['companies'].documents }

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

  let(:document) do
    {
      'id' => '124',
      'company_name' => 'Stark Industries',
      'num_employees' => 5215,
      'country' => 'USA'
    }
  end

  describe '#create' do
    it 'creates creates/indexes a document and returns it' do
      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents', typesense.configuration.nodes[0]))
        .with(body: document,
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

      result = companies_documents.create(document)

      expect(result).to eq(document)
    end
  end

  describe '#create_many' do
    it 'creates creates/indexes documents in bulk' do
      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/import', typesense.configuration.nodes[0]))
        .with(body: "#{JSON.dump(document)}\n#{JSON.dump(document)}",
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump({ 'success' => true }), headers: { 'Content-Type': 'text/plain' })

      result = companies_documents.create_many([document, document])

      expect(result).to eq([{ 'success' => true }])
    end
  end

  describe '#import' do
    it 'imports documents in JSONL format' do
      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/import', typesense.configuration.nodes[0]))
        .with(body: "#{JSON.dump(document)}\n#{JSON.dump(document)}",
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: '{}', headers: { 'Content-Type': 'application/json' })

      result = companies_documents.import("#{JSON.dump(document)}\n#{JSON.dump(document)}")

      expect(result).to eq({})
    end
  end

  describe '#export' do
    it 'exports all documents in a collection as an array' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/export', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: "#{JSON.dump(document)}\n#{JSON.dump(document)}")

      result = companies_documents.export

      expect(result).to eq("#{JSON.dump(document)}\n#{JSON.dump(document)}")
    end
  end

  describe '#search' do
    let(:search_parameters) do
      {
        'q' => 'Stark',
        'query_by' => 'company_name'
      }
    end

    let(:stubbed_search_result) do
      {
        'facet_counts' => [],
        'found' => 0,
        'search_time_ms' => 0,
        'page' => 0,
        'hits' => [
          {
            '_highlight' => {
              'company_name' => '<mark>Stark</mark> Industries'
            },
            'document' => {
              'id' => '124',
              'company_name' => 'Stark Industries',
              'num_employees' => 5215,
              'country' => 'USA'
            }
          }
        ]
      }
    end

    it 'search the documents in a collection' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/search', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              },
              query: search_parameters)
        .to_return(status: 200, body: JSON.dump(stubbed_search_result), headers: { 'Content-Type': 'application/json' })

      result = companies_documents.search(search_parameters)

      expect(result).to eq(stubbed_search_result)
    end
  end

  describe '#[]' do
    it 'creates a document object and returns it' do
      result = companies_documents['124']

      expect(result).to be_a_kind_of(Typesense::Document)
      expect(result.instance_variable_get(:@document_id)).to eq('124')
    end
  end
end
