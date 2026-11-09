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

    # Create or update an analytics rule with the given name.
    #
    # @example
    #   client.analytics.rules.upsert('products_click_counter', 'type' => 'counter', 'collection' => 'products', 'event_type' => 'click', 'params' => { 'counter_field' => 'popularity', 'weight' => 1 })
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    def upsert(rule_name, params)
      @api_call.put("#{self.class::RESOURCE_PATH}/#{URI.encode_www_form_component(rule_name)}", params)
    end

    # Retrieve all analytics rules. Pass `rule_tag` to only retrieve the rules with that tag.
    #
    # @example
    #   client.analytics.rules.retrieve
    # @example
    #   client.analytics.rules.retrieve(rule_tag: 'homepage')
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    def retrieve(params = {})
      @api_call.get(self.class::RESOURCE_PATH, params)
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
