# frozen_string_literal: true

module Typesense
  class Health
    RESOURCE_PATH = '/health'

    def initialize(api_call)
      @api_call = api_call
    end

    # Checks if Typesense server is ready to accept requests.
    #
    # @example
    #   client.health.retrieve
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html#health
    def retrieve
      @api_call.get(RESOURCE_PATH)
    end
  end
end
