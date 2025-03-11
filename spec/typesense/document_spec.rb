# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Document do
  subject(:document124) { typesense.collections['companies'].documents['124'] }

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
      'default_sorting_field' => 'num_employees'
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

  describe '#retrieve' do
    it 'returns the specified document' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/124', typesense.configuration.nodes[0]))
        .with(headers: {
                'Content-Type' => 'application/json',
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

      result = document124.retrieve

      expect(result).to eq(document)
    end
  end

  describe '#update' do
    it 'updates the specified document' do
      partial_document = {
        'id' => '124',
        'num_employees' => 5200
      }
      stub_request(:patch, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/124', typesense.configuration.nodes[0]))
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'X-Typesense-Api-Key' => typesense.configuration.api_key
          },
          query: {
            dirty_values: 'coerce_or_reject'
          }
        )
        .to_return(status: 200, body: JSON.dump(partial_document), headers: { 'Content-Type': 'application/json' })

      result = document124.update(partial_document, dirty_values: 'coerce_or_reject')

      expect(result).to eq(partial_document)
    end
  end

  describe '#delete' do
    it 'deletes the specified document' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/documents/124', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump(document), headers: { 'Content-Type': 'application/json' })

      result = document124.delete

      expect(result).to eq(document)
    end
  end
end
