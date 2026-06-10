# frozen_string_literal: true

module Typesense
  class Operations
    RESOURCE_PATH = '/operations'

    def initialize(api_call)
      @api_call = api_call
    end

    # Perform a cluster operation: snapshot, vote, cache/clear, db/compact, or a custom path.
    #
    # @example
    #   client.operations.perform('snapshot', 'snapshot_path' => '/tmp/snap')
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html
    def perform(operation_name, query_params = {})
      @api_call.post("#{RESOURCE_PATH}/#{operation_name}", {}, query_params)
    end
  end
end
