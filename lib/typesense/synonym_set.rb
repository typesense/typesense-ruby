# frozen_string_literal: true

module Typesense
  class SynonymSet
    def initialize(synonym_set_name, api_call)
      @synonym_set_name = synonym_set_name
      @api_call = api_call
    end

    def upsert(params)
      @api_call.put(endpoint_path, params)
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{SynonymSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@synonym_set_name)}"
    end
  end
end
