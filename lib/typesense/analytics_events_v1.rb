# frozen_string_literal: true

module Typesense
  class AnalyticsEventsV1
    RESOURCE_PATH = '/analytics/events'

    def initialize(api_call)
      @api_call = api_call
    end

    # Submit a single legacy v1 analytics event. The event must correspond to an existing analytics rule by name.
    #
    # @example
    #   client.analytics_v1.events.create('type' => 'click', 'name' => 'products_click', 'data' => {})
    #
    # @see https://typesense.org/docs/29.0/api/analytics-query-suggestions.html
    def create(params)
      @api_call.post(endpoint_path, params)
    end

    private

    def endpoint_path(operation = nil)
      "#{AnalyticsEventsV1::RESOURCE_PATH}#{"/#{URI.encode_www_form_component(operation)}" unless operation.nil?}"
    end
  end
end
