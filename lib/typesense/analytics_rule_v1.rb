# frozen_string_literal: true

module Typesense
  class AnalyticsRuleV1
    def initialize(rule_name, api_call)
      @rule_name = rule_name
      @api_call = api_call
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{AnalyticsRulesV1::RESOURCE_PATH}/#{URI.encode_www_form_component(@rule_name)}"
    end
  end
end
