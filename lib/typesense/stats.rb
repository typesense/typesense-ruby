# frozen_string_literal: true

module Typesense
  class Stats
    RESOURCE_PATH = '/stats.json'

    def initialize(api_call)
      @api_call = api_call
    end

    def retrieve
      @api_call.get(RESOURCE_PATH)
    end
  end
end
