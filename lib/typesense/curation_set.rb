# frozen_string_literal: true

module Typesense
  class CurationSet
    attr_reader :items

    def initialize(curation_set_name, api_call)
      @curation_set_name = curation_set_name
      @api_call = api_call
      @items = CurationSetItems.new(@curation_set_name, @api_call)
    end

    def upsert(curation_set_data)
      @api_call.put(endpoint_path, curation_set_data)
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{CurationSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@curation_set_name)}"
    end
  end
end
