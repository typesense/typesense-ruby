# frozen_string_literal: true

module Typesense
  class NlSearchModels
    RESOURCE_PATH = '/nl_search_models'

    def initialize(api_call)
      @api_call = api_call
      @nl_search_models = {}
    end

    def create(schema)
      @api_call.post(RESOURCE_PATH, schema)
    end

    def retrieve
      @api_call.get(RESOURCE_PATH)
    end

    def [](model_id)
      @nl_search_models[model_id] ||= NlSearchModel.new(model_id, @api_call)
    end
  end
end
