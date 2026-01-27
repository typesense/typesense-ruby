# frozen_string_literal: true

module Typesense
  class CurationSetItem
    def initialize(curation_set_name, item_id, api_call)
      @curation_set_name = curation_set_name
      @item_id = item_id
      @api_call = api_call
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def upsert(params)
      @api_call.put(endpoint_path, params)
    end

    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{CurationSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@curation_set_name)}/items/#{URI.encode_www_form_component(@item_id)}"
    end
  end
end
