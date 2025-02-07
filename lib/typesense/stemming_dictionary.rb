# frozen_string_literal: true

module Typesense
  class StemmingDictionary
    def initialize(id, api_call)
      @dict_id = id
      @api_call = api_call
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    private

    def endpoint_path
      "#{StemmingDictionaries::RESOURCE_PATH}/#{URI.encode_www_form_component(@dict_id)}"
    end
  end
end
