# frozen_string_literal: true

module Typesense
  class AnalyticsRules
    RESOURCE_PATH = '/analytics/rules'

    def initialize(api_call)
      @api_call = api_call
    end

    def create(rules)
      @api_call.post(self.class::RESOURCE_PATH, rules)
    end

    def retrieve
      @api_call.get(self.class::RESOURCE_PATH)
    end

    def [](rule_name)
      AnalyticsRule.new(rule_name, @api_call)
    end

    def respond_to_missing?(_method_name, _include_private = false)
      true
    end

    def method_missing(method_name, *_args, &_block)
      self[method_name.to_s]
    end
  end
end
