# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Collection do
  subject(:companies_collection) { typesense.collections['companies'] }

  include_context 'with Typesense configuration'

  let(:company_schema) do
    {
      'name' => 'companies',
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

  describe '#retrieve' do
    it 'returns the specified collection' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = companies_collection.retrieve

      expect(result).to eq(company_schema)
    end
  end

  describe '#update' do
    it 'updates the specified collection' do
      update_schema = {
        'fields' => [
          'name' => 'field', 'drop' => true
        ]
      }
      stub_request(:patch, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies', typesense.configuration.nodes[0]))
        .with(
          body: update_schema,
          headers: {
            'X-Typesense-Api-Key' => typesense.configuration.api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(status: 200, body: JSON.dump(company_schema), headers: { 'Content-Type': 'application/json' })

      result = companies_collection.update(update_schema)

      expect(result).to eq(company_schema)
    end
  end

  describe '#delete' do
    it 'deletes the specified collection' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies', typesense.configuration.nodes[0]))
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

      expect(result).to be_a(Typesense::Documents)
    end
  end
end
