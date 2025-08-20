# frozen_string_literal: true

module Typesense
  class AnalyticsEventsV1
    RESOURCE_PATH = '/analytics/events'

    def initialize(api_call)
      @api_call = api_call
    end

    def create(params)
      @api_call.post(endpoint_path, params)
    end

    private

    def endpoint_path(operation = nil)
      "#{AnalyticsEventsV1::RESOURCE_PATH}#{"/#{URI.encode_www_form_component(operation)}" unless operation.nil?}"
    end
  end
end
