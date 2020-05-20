# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Override do
  include_context 'with Typesense configuration'

  subject(:override) { typesense.collections['companies'].overrides['lex-exact'] }

  let(:override_data) do
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

  describe '#retrieve' do
    it 'returns the specified override' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/overrides/lex-exact', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type': 'application/json'
              })
        .to_return(status: 200, body: JSON.dump(override_data), headers: { 'Content-Type': 'application/json' })

      result = override.retrieve

      expect(result).to eq(override_data)
    end
  end

  describe '#delete' do
    it 'deletes the specified override' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/collections/companies/overrides/lex-exact', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump('id' => 'lex-exact'), headers: { 'Content-Type': 'application/json' })

      result = override.delete

      expect(result).to eq('id' => 'lex-exact')
    end
  end
end
