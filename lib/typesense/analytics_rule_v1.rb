# frozen_string_literal: true

module Typesense
  class AnalyticsRuleV1
    def initialize(rule_name, api_call)
      @rule_name = rule_name
      @api_call = api_call
    end

    # Retrieve a legacy v1 analytics rule by name.
    #
    # @example
    #   client.analytics_v1.rules['rule-1'].retrieve
    #
    # @see https://typesense.org/docs/29.0/api/analytics-query-suggestions.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Delete a legacy v1 analytics rule by name.
    #
    # @example
    #   client.analytics_v1.rules['rule-1'].delete
    #
    # @see https://typesense.org/docs/29.0/api/analytics-query-suggestions.html
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{AnalyticsRulesV1::RESOURCE_PATH}/#{URI.encode_www_form_component(@rule_name)}"
    end
  end
end
