# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::AnalyticsRules do
  subject(:analytics_rules) { typesense.analytics.rules }

  include_context 'with Typesense configuration'

  let(:analytics_rule) do
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

  describe '#upsert' do
    it 'creates a rule and returns it' do
      stub_request(:put, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/analytics/rules/search_suggestions', typesense.configuration.nodes[0]))
        .with(body: analytics_rule,
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 201, body: JSON.dump(analytics_rule), headers: { 'Content-Type': 'application/json' })

      result = typesense.analytics.rules.upsert(analytics_rule['name'], analytics_rule)

      expect(result).to eq(analytics_rule)
    end
  end

  describe '#retrieve' do
    it 'retrieves all analytics rules' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/analytics/rules', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 201, body: JSON.dump([analytics_rule]), headers: { 'Content-Type': 'application/json' })

      result = analytics_rules.retrieve

      expect(result).to eq([analytics_rule])
    end
  end

  describe '#[]' do
    it 'creates an analytics rule object and returns it' do
      result = analytics_rules['search_suggestions']

      expect(result).to be_a(Typesense::AnalyticsRule)
      expect(result.instance_variable_get(:@rule_name)).to eq('search_suggestions')
    end
  end
end
