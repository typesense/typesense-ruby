# frozen_string_literal: true

module Typesense
  class MultiSearch
    RESOURCE_PATH = '/multi_search'

    def initialize(api_call)
      @api_call = api_call
    end

    def perform(searches, query_params = {})
      @api_call.post(RESOURCE_PATH, searches, query_params)
    end
  end
end
