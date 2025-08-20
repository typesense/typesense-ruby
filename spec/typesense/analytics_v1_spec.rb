# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::AnalyticsV1 do
  subject(:analytics_v1) { typesense.analytics_v1 }

  include_context 'with Typesense configuration'

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
  end

  describe '#rules' do
    it 'returns an AnalyticsRulesV1 instance' do
      expect(analytics_v1.rules).to be_a(Typesense::AnalyticsRulesV1)
    end

    it 'memoizes the rules instance' do
      first_call = analytics_v1.rules
      second_call = analytics_v1.rules
      expect(first_call).to equal(second_call)
    end
  end

  describe '#events' do
    it 'returns an AnalyticsEventsV1 instance' do
      expect(analytics_v1.events).to be_a(Typesense::AnalyticsEventsV1)
    end

    it 'memoizes the events instance' do
      first_call = analytics_v1.events
      second_call = analytics_v1.events
      expect(first_call).to equal(second_call)
    end
  end

  context 'with integration tests', :integration do
    before do
      WebMock.disable!

      # Create test collections for v1 analytics
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

      begin
        integration_client.collections.create({
                                                'name' => 'product_queries',
                                                'fields' => [
                                                  { 'name' => 'query', 'type' => 'string' },
                                                  { 'name' => 'count', 'type' => 'int32' }
                                                ]
                                              })
      rescue Typesense::Error::ObjectAlreadyExists
        # Collection already exists, which is fine
      end
    end

    after do
      # Clean up test collections
      begin
        integration_client.collections['products'].delete
      rescue StandardError
        # Ignore cleanup errors
      end

      begin
        integration_client.collections['product_queries'].delete
      rescue StandardError
        # Ignore cleanup errors
      end

      WebMock.enable!
    end

    it 'can create and use analytics rules with v1 API' do
      # Create a rule using v1 API
      rule_config = {
        'type' => 'popular_queries',
        'params' => {
          'source' => {
            'collections' => ['products']
          },
          'destination' => {
            'collection' => 'product_queries'
          },
          'expand_query' => false,
          'limit' => 100
        }
      }

      # This should work with v1 API - name is passed separately
      integration_client.analytics_v1.rules.upsert('products_popularity', rule_config)

      # Verify the rule was created
      rules = integration_client.analytics_v1.rules.retrieve
      expect(rules).to be_a(Hash)
      expect(rules['rules']).to be_an(Array)

      # Clean up
      integration_client.analytics_v1.rules['products_popularity'].delete
    end
  end
end
