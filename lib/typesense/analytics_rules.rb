# frozen_string_literal: true

module Typesense
  class AnalyticsRules
    RESOURCE_PATH = '/analytics/rules'

    def initialize(api_call)
      @api_call        = api_call
      @analytics_rules = {}
    end

    def upsert(rule_name, params)
      @api_call.put(endpoint_path(rule_name), params)
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def [](rule_name)
      @analytics_rules[rule_name] ||= AnalyticsRule.new(rule_name, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{AnalyticsRules::RESOURCE_PATH}#{operation.nil? ? '' : "/#{URI.encode_www_form_component(operation)}"}"
    end
  end
end
