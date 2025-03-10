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
              },
              query: {
                'dirty_values' => 'coerce_or_reject'
              })
        .to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

      result = companies_documents.create(document, dirty_values: 'coerce_or_reject')

      expect(result).to eq(document)
    end
  end

  describe '#update' do
    context 'when using update by query' do
      it 'updates the document and returns it' do
        stub_request(:patch, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents', typesense.configuration.nodes[0]))
          .with(body: document,
                headers: {
                  'X-Typesense-Api-Key' => typesense.configuration.api_key,
                  'Content-Type' => 'application/json'
                },
                query: {
                  'filter_by' => 'field:=value',
                  'dirty_values' => 'coerce_or_reject'
                })
          .to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

        result = companies_documents.update(document, dirty_values: 'coerce_or_reject', filter_by: 'field:=value')

        expect(result).to eq(document)
      end
    end

    it 'updates the document and returns it' do
      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents', typesense.configuration.nodes[0]))
        .with(body: document,
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              },
              query: {
                'action' => 'update',
                'dirty_values' => 'coerce_or_reject'
              })
        .to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

      result = companies_documents.update(document, dirty_values: 'coerce_or_reject')

      expect(result).to eq(document)
    end
  end

  describe '#upserts' do
    it 'upserts the document and returns it' do
      stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents', typesense.configuration.nodes[0]))
        .with(body: document,
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              },
              query: {
                'action' => 'upsert',
                'dirty_values' => 'coerce_or_reject'
              })
        .to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

      result = companies_documents.upsert(document, dirty_values: 'coerce_or_reject')

      expect(result).to eq(document)
    end
  end

  describe '#create_many' do
    context 'when no options are specified' do
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

    context 'when an option is specified' do
      it 'creates creates/indexes documents in bulk, with the option' do
        stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/import', typesense.configuration.nodes[0]))
          .with(body: "#{JSON.dump(document)}\n#{JSON.dump(document)}",
                headers: {
                  'X-Typesense-Api-Key' => typesense.configuration.api_key
                },
                query: {
                  'upsert' => 'true'
                })
          .to_return(status: 200, body: JSON.dump({ 'success' => true }), headers: { 'Content-Type': 'text/plain' })

        result = companies_documents.create_many([document, document], upsert: true)

        expect(result).to eq([{ 'success' => true }])
      end
    end
  end

  describe '#import' do
    context 'when an option is specified' do
      it 'passes the option to the API' do
        stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/import', typesense.configuration.nodes[0]))
          .with(body: "#{JSON.dump(document)}\n#{JSON.dump(document)}",
                headers: {
                  'X-Typesense-Api-Key' => typesense.configuration.api_key
                },
                query: {
                  'action' => 'upsert'
                })
          .to_return(status: 200, body: '{}', headers: { 'Content-Type': 'text/plain' })

        result = companies_documents.import("#{JSON.dump(document)}\n#{JSON.dump(document)}", action: :upsert)

        expect(result).to eq('{}')
      end
    end

    context 'when an array of docs is passed' do
      it 'converts it to JSONL and returns an array of results' do
        stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/import', typesense.configuration.nodes[0]))
          .with(body: "#{JSON.dump(document)}\n#{JSON.dump(document)}",
                headers: {
                  'X-Typesense-Api-Key' => typesense.configuration.api_key
                })
          .to_return(status: 200, body: "{}\n{}", headers: { 'Content-Type': 'text/plain' })

        result = companies_documents.import([document, document])

        expect(result).to eq([{}, {}])
      end
    end

    context 'when a JSONL string is passed' do
      it 'sends the string as is and returns a string' do
        stub_request(:post, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/import', typesense.configuration.nodes[0]))
          .with(body: "#{JSON.dump(document)}\n#{JSON.dump(document)}",
                headers: {
                  'X-Typesense-Api-Key' => typesense.configuration.api_key
                })
          .to_return(status: 200, body: "{}\n{}", headers: { 'Content-Type': 'text/plain' })

        result = companies_documents.import("#{JSON.dump(document)}\n#{JSON.dump(document)}")

        expect(result).to eq("{}\n{}")
      end
    end
  end

  describe '#export' do
    it 'exports all documents in a collection as an array' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/export', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              },
              query: {
                'include_fields' => 'field1'
              })
        .to_return(status: 200, body: "#{JSON.dump(document)}\n#{JSON.dump(document)}")

      result = companies_documents.export(include_fields: 'field1')

      expect(result).to eq("#{JSON.dump(document)}\n#{JSON.dump(document)}")
    end
  end

  describe '#delete' do
    it 'delete documents in a collection' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              },
              query: {
                filter_by: 'field:=value'
              })
        .to_return(status: 200, body: '{}', headers: { 'Content-Type': 'application/json' })

      result = companies_documents.delete(filter_by: 'field:=value')

      expect(result).to eq({})
    end
  end

  describe '#truncate' do
    it 'truncate documents in a collection' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              },
              query: {
                truncate: true
              })
        .to_return(status: 200, body: '{ "num_deleted": 1 }', headers: { 'Content-Type': 'application/json' })

      result = companies_documents.truncate

      expect(result['num_deleted']).to eq(1)
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

      expect(result).to be_a(Typesense::Document)
      expect(result.instance_variable_get(:@document_id)).to eq('124')
    end
  end
end
