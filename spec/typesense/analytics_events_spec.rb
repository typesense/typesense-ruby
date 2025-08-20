# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::AnalyticsEvents do
  subject(:analytics_events) { typesense.analytics.events }

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
    it 'creates an analytics event and returns it' do
      event = {
        'name' => rule_name,
        'event_type' => 'click',
        'data' => {
          'doc_id' => '1',
          'user_id' => 'test_user'
        }
      }

      result = integration_client.analytics.events.create(event)
      expect(result).to be_a(Hash)
    end
  end

  describe '#retrieve' do
    it 'retrieves analytics events with query parameters' do
      event = {
        'name' => rule_name,
        'event_type' => 'click',
        'data' => {
          'doc_id' => '1',
          'user_id' => 'test_user'
        }
      }

      integration_client.analytics.events.create(event)

      result = integration_client.analytics.events.retrieve({
                                                              'user_id' => 'test_user',
                                                              'name' => rule_name,
                                                              'n' => 10
                                                            })

      expect(result).to be_a(Hash)
      expect(result['events']).to be_a(Array)
    end
  end

  describe 'event creation with different event types' do
    it 'creates click and conversion events' do
      click_event = {
        'name' => rule_name,
        'event_type' => 'click',
        'data' => {
          'doc_id' => '1',
          'user_id' => 'test_user'
        }
      }

      conversion_event = {
        'name' => rule_name,
        'event_type' => 'conversion',
        'data' => {
          'doc_id' => '1',
          'user_id' => 'test_user'
        }
      }

      click_response = integration_client.analytics.events.create(click_event)
      expect(click_response).to be_a(Hash)

      conversion_response = integration_client.analytics.events.create(conversion_event)
      expect(conversion_response).to be_a(Hash)
    end
  end
end
