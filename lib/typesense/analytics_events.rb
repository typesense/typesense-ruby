# frozen_string_literal: true

module Typesense
  class AnalyticsEvents
    RESOURCE_PATH = '/analytics/events'

    def initialize(api_call)
      @api_call = api_call
    end

    # Submit a single analytics event. The event must correspond to an existing analytics rule by name.
    #
    # @example
    #   client.analytics.events.create('type' => 'click', 'name' => 'products_click', 'data' => {})
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    def create(params)
      @api_call.post(self.class::RESOURCE_PATH, params)
    end

    # Retrieve the most recent events for a user and rule.
    #
    # @example
    #   client.analytics.events.retrieve('user_id' => 'u1', 'name' => 'products_click', 'n' => 10)
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    def retrieve(params = {})
      @api_call.get(self.class::RESOURCE_PATH, params)
    end
  end
end
