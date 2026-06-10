# frozen_string_literal: true

module Typesense
  # @deprecated Deprecated starting with Typesense Server v30. Please migrate to `client.analytics` (new Analytics APIs).
  class AnalyticsV1
    RESOURCE_PATH = '/analytics'

    def initialize(api_call)
      @api_call = api_call
    end

    # Access the legacy v1 analytics rules resource. Use it to list or upsert rules, or as an array
    # to access a single rule by ID.
    #
    # @example
    #   client.analytics_v1.rules.retrieve
    # @example
    #   client.analytics_v1.rules['rule-1'].retrieve
    #
    # @see https://typesense.org/docs/29.0/api/analytics-query-suggestions.html
    #
    # @return [AnalyticsRulesV1]
    def rules
      @rules ||= AnalyticsRulesV1.new(@api_call)
    end

    # Access the legacy v1 analytics events resource to send analytics events.
    #
    # @example
    #   client.analytics_v1.events.create('type' => 'click', 'name' => 'products_click', 'data' => {})
    #
    # @see https://typesense.org/docs/29.0/api/analytics-query-suggestions.html
    #
    # @return [AnalyticsEventsV1]
    def events
      @events ||= AnalyticsEventsV1.new(@api_call)
    end
  end
end
