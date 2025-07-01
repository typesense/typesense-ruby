# frozen_string_literal: true

module Typesense
  class NlSearchModel
    def initialize(model_id, api_call)
      @model_id = model_id
      @api_call = api_call
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def update(update_schema)
      @api_call.put(endpoint_path, update_schema)
    end

    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{NlSearchModels::RESOURCE_PATH}/#{URI.encode_www_form_component(@model_id)}"
    end
  end
end 