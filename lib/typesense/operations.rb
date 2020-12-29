# frozen_string_literal: true

module Typesense
  class Operations
    RESOURCE_PATH = '/operations'

    def initialize(api_call)
      @api_call = api_call
    end

    def perform(operation_name, query_params = {})
      @api_call.post("#{RESOURCE_PATH}/#{operation_name}", {}, query_params)
    end
  end
end
