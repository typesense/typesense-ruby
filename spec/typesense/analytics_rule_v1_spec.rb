# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::AnalyticsRuleV1 do
  subject(:analytics_rule_v1) { typesense.analytics_v1.rules[rule_name] }

  include_context 'with Typesense configuration'

  let(:rule_name) { 'test_rule' }
  let(:rule_configuration) do
    {
      'type' => 'popular_queries',
      'params' => {
        'source' => { 'collections' => ['products'] },
        'destination' => { 'collection' => 'product_queries' },
        'expand_query' => false,
        'limit' => 100
      }
    }
  end

  let(:integration_client) do
    Typesense::Client.new(
      nodes: [{
        host: 'localhost',
        port: '8108',
        protocol: 'http'
      }],
      api_key: 'xyz',
      connection_timeout_seconds: 10
    )
  end

  before do
    skip('Analytics is deprecated in Typesense v30+') if typesense_v30_or_above?

    WebMock.disable!

    # Create test collection for v1 analytics
    begin
      integration_client.collections.create({
                                              'name' => 'products',
                                              'fields' => [
                                                { 'name' => 'title', 'type' => 'string' },
                                                { 'name' => 'popularity', 'type' => 'int32', 'optional' => true }
                                              ]
                                            })
    rescue Typesense::Error::ObjectAlreadyExists
      # Collection already exists, which is fine
    end

    # Create test rule
    begin
      integration_client.analytics_v1.rules.upsert(rule_name, rule_configuration)
    rescue StandardError
      # Rule creation might fail, which is fine for testing
    end
  end

  after do
    # Clean up test rules
    begin
      rules = integration_client.analytics_v1.rules.retrieve
      if rules.is_a?(Hash) && rules['rules']
        rules['rules'].each do |rule|
          integration_client.analytics_v1.rules[rule['name']].delete
        rescue StandardError
          # Ignore cleanup errors
        end
      end
    rescue StandardError
      # Ignore cleanup errors
    end

    # Clean up test collection
    begin
      integration_client.collections['products'].delete
    rescue StandardError
      # Ignore cleanup errors
    end

    WebMock.enable!
  end

  describe '#retrieve' do
    it 'returns the specified analytics rule' do
      result = integration_client.analytics_v1.rules[rule_name].retrieve

      expect(result['name']).to eq(rule_name)
      expect(result['type']).to eq('popular_queries')
    end
  end

  describe '#delete' do
    it 'deletes the specified analytics rule' do
      result = integration_client.analytics_v1.rules[rule_name].delete
      expect(result['name']).to eq(rule_name)

      # Verify the rule is deleted
      expect do
        integration_client.analytics_v1.rules[rule_name].retrieve
      end.to raise_error(Typesense::Error::ObjectNotFound)
    end
  end
end
