# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::AnalyticsRule do
  subject(:analytics_rule) { typesense.analytics.rules['search_suggestions'] }

  include_context 'with Typesense configuration'

  let(:analytics_rule_data) do
    {
      'name' => 'search_suggestions',
      'type' => 'popular_queries',
      'params' => {
        'source' => { 'collections' => ['products'] },
        'destination' => { 'collection' => 'products_top_queries' },
        'limit' => 100
      }
    }
  end

  describe '#retrieve' do
    it 'returns the specified analytics rule' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/analytics/rules/search_suggestions', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type': 'application/json'
              })
        .to_return(status: 200, body: JSON.dump(analytics_rule_data), headers: { 'Content-Type': 'application/json' })

      result = analytics_rule.retrieve

      expect(result).to eq(analytics_rule_data)
    end
  end

  describe '#delete' do
    it 'deletes the specified analytics rule' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/analytics/rules/search_suggestions', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump('name' => 'search_suggestions'), headers: { 'Content-Type': 'application/json' })

      result = analytics_rule.delete

      expect(result).to eq('name' => 'search_suggestions')
    end
  end
end
