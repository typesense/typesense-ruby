# frozen_string_literal: true

module Typesense
  class Metrics
    RESOURCE_PATH = '/metrics.json'

    def initialize(api_call)
      @api_call = api_call
    end

    # Get current RAM, CPU, Disk & Network usage metrics.
    #
    # @example
    #   client.metrics.retrieve
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html
    def retrieve
      @api_call.get(RESOURCE_PATH)
    end
  end
end
