# frozen_string_literal: true

module Typesense
  class AnalyticsRule
    def initialize(rule_name, api_call)
      @rule_name = rule_name
      @api_call = api_call
    end

    # Retrieve the details of an analytics rule, given it's name
    #
    # @example
    #   client.analytics.rules['rule-1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Permanently deletes an analytics rule, given it's name
    #
    # @example
    #   client.analytics.rules['rule-1'].delete
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    def delete
      @api_call.delete(endpoint_path)
    end

    # Upserts an analytics rule with the given name.
    #
    # @example
    #   client.analytics.rules['products_query_hits'].update('type' => 'popular_queries', 'params' => {})
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    def update(params)
      @api_call.put(endpoint_path, params)
    end

    private

    def endpoint_path
      "#{AnalyticsRules::RESOURCE_PATH}/#{URI.encode_www_form_component(@rule_name)}"
    end
  end
end
