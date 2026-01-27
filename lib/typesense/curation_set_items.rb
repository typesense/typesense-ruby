# frozen_string_literal: true

module Typesense
  class CurationSetItems
    def initialize(curation_set_name, api_call)
      @curation_set_name = curation_set_name
      @api_call = api_call
      @items = {}
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def [](item_id)
      @items[item_id] ||= CurationSetItem.new(@curation_set_name, item_id, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{CurationSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@curation_set_name)}/items#{"/#{operation}" unless operation.nil?}"
    end
  end
end
