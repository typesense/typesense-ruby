# frozen_string_literal: true

module Typesense
  class AnalyticsV1
    RESOURCE_PATH = '/analytics'

    def initialize(api_call)
      @api_call = api_call
    end

    def rules
      @rules ||= AnalyticsRulesV1.new(@api_call)
    end

    def events
      @events ||= AnalyticsEventsV1.new(@api_call)
    end
  end
end
