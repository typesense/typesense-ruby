# frozen_string_literal: true

module Typesense
  class AnalyticsRulesV1
    RESOURCE_PATH = '/analytics/rules'

    def initialize(api_call)
      @api_call        = api_call
      @analytics_rules = {}
    end

    # Upsert a legacy v1 analytics rule by name.
    #
    # @example
    #   client.analytics_v1.rules.upsert('products_query_hits', 'type' => 'popular_queries', 'params' => {})
    #
    # @see https://typesense.org/docs/29.0/api/analytics-query-suggestions.html
    def upsert(rule_name, params)
      @api_call.put(endpoint_path(rule_name), params)
    end

    # Retrieve all legacy v1 analytics rules.
    #
    # @example
    #   client.analytics_v1.rules.retrieve
    #
    # @see https://typesense.org/docs/29.0/api/analytics-query-suggestions.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Access an individual legacy v1 analytics rule by name.
    #
    # @example
    #   client.analytics_v1.rules['rule-1'].retrieve
    #
    # @see https://typesense.org/docs/29.0/api/analytics-query-suggestions.html
    #
    # @return [AnalyticsRuleV1]
    def [](rule_name)
      @analytics_rules[rule_name] ||= AnalyticsRuleV1.new(rule_name, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{AnalyticsRulesV1::RESOURCE_PATH}#{"/#{URI.encode_www_form_component(operation)}" unless operation.nil?}"
    end
  end
end
