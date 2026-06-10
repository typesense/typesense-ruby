# frozen_string_literal: true

module Typesense
  class AnalyticsRules
    RESOURCE_PATH = '/analytics/rules'

    def initialize(api_call)
      @api_call = api_call
    end

    # Create one or more analytics rules. You can send a single rule object or an array of rule objects.
    #
    # @example
    #   client.analytics.rules.create('name' => 'products_query_hits', 'type' => 'popular_queries', 'params' => {})
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    def create(rules)
      @api_call.post(self.class::RESOURCE_PATH, rules)
    end

    # Retrieve all analytics rules.
    #
    # @example
    #   client.analytics.rules.retrieve
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    def retrieve
      @api_call.get(self.class::RESOURCE_PATH)
    end

    # Access an individual analytics rule by name.
    #
    # @example
    #   client.analytics.rules['rule-1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    #
    # @return [AnalyticsRule]
    def [](rule_name)
      AnalyticsRule.new(rule_name, @api_call)
    end
  end
end
