# frozen_string_literal: true

module Typesense
  class AnalyticsRule
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
      "#{AnalyticsRules::RESOURCE_PATH}/#{@rule_name}"
    end
  end
end
