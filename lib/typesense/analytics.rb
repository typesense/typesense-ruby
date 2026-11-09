# frozen_string_literal: true

module Typesense
  class Analytics
    RESOURCE_PATH = '/analytics'

    def initialize(api_call)
      @api_call = api_call
    end

    # Access the analytics rules resource. Use it to list or create rules, or as an array
    # to access a single rule by ID.
    #
    # @example
    #   client.analytics.rules.retrieve
    # @example
    #   client.analytics.rules['rule-1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    #
    # @return [AnalyticsRules]
    def rules
      @rules ||= AnalyticsRules.new(@api_call)
    end

    # Access the analytics events resource to send analytics events.
    #
    # @example
    #   client.analytics.events.create('type' => 'click', 'name' => 'products_click', 'data' => {})
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    #
    # @return [AnalyticsEvents]
    def events
      @events ||= AnalyticsEvents.new(@api_call)
    end
  end
end
