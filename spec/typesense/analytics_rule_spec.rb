# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::AnalyticsRule do
  subject(:analytics_rule) { typesense.analytics.rules[rule_name] }

  include_context 'with Typesense configuration'

  let(:rule_name) { 'test__rule' }
  let(:rule_configuration) do
    {
      'name' => rule_name,
      'type' => 'counter',
      'collection' => 'test_products',
      'event_type' => 'click',
      'rule_tag' => 'test_tag',
      'params' => {
        'counter_field' => 'popularity',
        'weight' => 1
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
    skip('New Analytics API is not supported in Typesense 29.0 and below') unless typesense_v30_or_above?

    WebMock.disable!

    # Create test collection
    begin
      integration_client.collections.create({
                                              'name' => 'test_products',
                                              'fields' => [
                                                { 'name' => 'company_name', 'type' => 'string' },
                                                { 'name' => 'num_employees', 'type' => 'int32' },
                                                { 'name' => 'country', 'type' => 'string', 'facet' => true },
                                                { 'name' => 'popularity', 'type' => 'int32', 'optional' => true }
                                              ],
                                              'default_sorting_field' => 'num_employees'
                                            })
    rescue Typesense::Error::ObjectAlreadyExists
      # Collection already exists, which is fine
    end

    # Create test rule
    begin
      integration_client.analytics.rules.create([rule_configuration])
    rescue StandardError
      # Rule creation might fail, which is fine for testing
    end
  end

  after do
    # Clean up test rules
    begin
      rules = integration_client.analytics.rules.retrieve
      if rules.is_a?(Array)
        rules.each do |rule|
          next unless rule['name'].to_s.start_with?('test__')

          begin
            integration_client.analytics.rules[rule['name']].delete
          rescue StandardError
            # Ignore cleanup errors
          end
        end
      end
    rescue StandardError
      # Ignore cleanup errors
    end

    # Clean up test collection
    begin
      integration_client.collections['test_products'].delete
    rescue StandardError
      # Ignore cleanup errors
    end

    WebMock.enable!
  end

  describe '#retrieve' do
    it 'returns the specified analytics rule' do
      result = integration_client.analytics.rules[rule_name].retrieve

      expect(result['name']).to eq(rule_name)
      expect(result['type']).to eq('counter')
      expect(result['collection']).to eq('test_products')
    end
  end

  describe '#delete' do
    it 'deletes the specified analytics rule' do
      result = integration_client.analytics.rules[rule_name].delete
      expect(result['name']).to eq(rule_name)

      # Verify the rule is deleted
      expect do
        integration_client.analytics.rules[rule_name].retrieve
      end.to raise_error(Typesense::Error::RequestMalformed)
    end
  end

  describe '#update' do
    it 'updates the specified analytics rule' do
      update_params = {
        'type' => 'counter',
        'collection' => 'test_products',
        'event_type' => 'click',
        'rule_tag' => 'updated_tag',
        'params' => {
          'counter_field' => 'popularity',
          'weight' => 5
        }
      }

      result = integration_client.analytics.rules[rule_name].update(update_params)

      expect(result['name']).to eq(rule_name)
      expect(result['rule_tag']).to eq('updated_tag')
      expect(result['params']['weight']).to eq(5)
    end
  end

  describe '#upsert' do
    it 'is aliased as #update' do
      expect(described_class.instance_method(:update)).to eq(described_class.instance_method(:upsert))
    end

    it 'creates the analytics rule if it does not exist yet' do
      result = integration_client.analytics.rules['test__new_rule'].upsert(rule_configuration.except('name'))

      expect(result['name']).to eq('test__new_rule')
      expect(integration_client.analytics.rules['test__new_rule'].retrieve['type']).to eq('counter')
    end
  end
end
