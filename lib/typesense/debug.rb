# frozen_string_literal: true

module Typesense
  class Debug
    RESOURCE_PATH = '/debug'

    def initialize(api_call)
      @api_call = api_call
    end

    # Retrieve server version and state information.
    #
    # @example
    #   client.debug.retrieve
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html#debug
    def retrieve
      @api_call.get(RESOURCE_PATH)
    end
  end
end
