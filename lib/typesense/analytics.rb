# frozen_string_literal: true

module Typesense
  class Analytics
    RESOURCE_PATH = '/analytics'

    def initialize(api_call)
      @api_call = api_call
    end

    def rules
      @rules ||= AnalyticsRules.new(@api_call)
    end
  end
end
