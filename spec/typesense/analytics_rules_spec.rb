# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::AnalyticsRules do
  subject(:analytics_rules) { typesense.analytics.rules }

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

    begin
      integration_client.analytics.rules.create([rule_configuration])
    rescue StandardError
      # Rule creation might fail, which is fine for testing
    end
  end

  after do
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

    begin
      integration_client.collections['test_products'].delete
    rescue StandardError
      # Ignore cleanup errors
    end

    WebMock.enable!
  end

  describe '#create' do
    it 'creates multiple rules and returns them' do
      rules = [
        {
          'name' => 'test_rule_1',
          'type' => 'counter',
          'collection' => 'test_products',
          'event_type' => 'click',
          'rule_tag' => 'test_tag',
          'params' => {
            'counter_field' => 'popularity',
            'weight' => 1
          }
        },
        {
          'name' => 'test_rule_2',
          'type' => 'counter',
          'collection' => 'test_products',
          'event_type' => 'conversion',
          'rule_tag' => 'test_tag',
          'params' => {
            'counter_field' => 'popularity',
            'weight' => 2
          }
        }
      ]

      result = integration_client.analytics.rules.create(rules)
      expect(result).to be_a(Array)

      all_rules = integration_client.analytics.rules.retrieve
      expect(all_rules).to be_a(Array)

      rule_names = all_rules.map { |rule| rule['name'] }
      expect(rule_names).to include('test_rule_1')
      expect(rule_names).to include('test_rule_2')
    end
  end

  describe '#retrieve' do
    it 'retrieves all analytics rules' do
      result = integration_client.analytics.rules.retrieve
      expect(result).to be_a(Array)
      expect(result.length).to be >= 1

      rule_names = result.map { |rule| rule['name'] }
      expect(rule_names).to include(rule_name)
    end
  end

  describe '#[]' do
    it 'creates an analytics rule object and returns it' do
      result = integration_client.analytics.rules[rule_name]

      expect(result).to be_a(Typesense::AnalyticsRule)
      expect(result.instance_variable_get(:@rule_name)).to eq(rule_name)
    end

    it 'does not memoize the analytics rule instance' do
      first_call = integration_client.analytics.rules[rule_name]
      second_call = integration_client.analytics.rules[rule_name]
      expect(first_call).not_to equal(second_call)
    end
  end
end
