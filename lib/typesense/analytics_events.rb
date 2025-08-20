# frozen_string_literal: true

module Typesense
  class AnalyticsEvents
    RESOURCE_PATH = '/analytics/events'

    def initialize(api_call)
      @api_call = api_call
    end

    def create(params)
      @api_call.post(self.class::RESOURCE_PATH, params)
    end

    def retrieve(params = {})
      @api_call.get(self.class::RESOURCE_PATH, params)
    end
  end
end
