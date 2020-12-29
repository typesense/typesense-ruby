# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Overrides do
  subject(:companies_overrides) { typesense.collections['companies'].overrides }

  include_context 'with Typesense configuration'

  let(:override) do
    {
      'id' => 'lex-exact',
      'rule' => {
        'query' => 'lex luthor',
        'match' => 'exact'
      },
      'includes' => [{ 'id' => '125', 'position' => 1 }],
      'excludes' => [{ 'id' => '124' }]
    }
  end

  describe '#upsert' do
    it 'creates an override rule and returns it' do
      stub_request(:put, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/overrides/lex-exact', typesense.configuration.nodes[0]))
        .with(body: override,
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 201, body: JSON.dump(override), headers: { 'Content-Type': 'application/json' })

      result = companies_overrides.upsert(override['id'], override)

      expect(result).to eq(override)
    end
  end

  describe '#retrieve' do
    it 'retrieves all overrides' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/overrides', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 201, body: JSON.dump([override]), headers: { 'Content-Type': 'application/json' })

      result = companies_overrides.retrieve

      expect(result).to eq([override])
    end
  end

  describe '#[]' do
    it 'creates an override object and returns it' do
      result = companies_overrides['lex-override']

      expect(result).to be_a_kind_of(Typesense::Override)
      expect(result.instance_variable_get(:@override_id)).to eq('lex-override')
    end
  end
end
