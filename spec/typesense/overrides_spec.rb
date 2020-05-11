# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Overrides do
  include_context 'with Typesense configuration'

  subject(:companies_overrides) { typesense.collections['companies'].overrides }

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

  describe '#create' do
    it 'creates an override rule and returns it' do
      stub_request(:put, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/overrides', 0))
        .with(body: override,
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 201, body: JSON.dump(override), headers: { 'Content-Type': 'application/json' })

      result = companies_overrides.create(override)

      expect(result).to eq(override)
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
