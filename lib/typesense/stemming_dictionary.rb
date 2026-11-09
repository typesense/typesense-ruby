# frozen_string_literal: true

module Typesense
  class StemmingDictionary
    def initialize(id, api_call)
      @dict_id = id
      @api_call = api_call
    end

    # Fetch details of a specific stemming dictionary.
    #
    # @example
    #   client.stemming.dictionaries['en'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/stemming.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    private

    def endpoint_path
      "#{StemmingDictionaries::RESOURCE_PATH}/#{URI.encode_www_form_component(@dict_id)}"
    end
  end
end
