# frozen_string_literal: true

module Typesense
  class Stats
    RESOURCE_PATH = '/stats.json'

    def initialize(api_call)
      @api_call = api_call
    end

    # Get stats about API endpoints.
    #
    # @example
    #   client.stats.retrieve
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html
    def retrieve
      @api_call.get(RESOURCE_PATH)
    end
  end
end
