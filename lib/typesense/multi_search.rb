# frozen_string_literal: true

module Typesense
  class MultiSearch
    RESOURCE_PATH = '/multi_search'

    def initialize(api_call)
      @api_call = api_call
    end

    # Send multiple search requests in a single HTTP request. Pass `union: true` to merge results, or omit it to receive a `results` array.
    #
    # @example
    #   client.multi_search.perform('searches' => [{ 'collection' => 'products', 'q' => '*' }])
    # @example
    #   client.multi_search.perform('union' => true, 'searches' => [{ 'collection' => 'products', 'q' => '*' }])
    #
    # @see https://typesense.org/docs/latest/api/documents.html#federated-multi-search
    def perform(searches, query_params = {})
      @api_call.post(RESOURCE_PATH, searches, query_params)
    end
  end
end
