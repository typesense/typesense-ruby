# frozen_string_literal: true

module Typesense
  class CurationSetItems
    def initialize(curation_set_name, api_call)
      @curation_set_name = curation_set_name
      @api_call = api_call
      @items = {}
    end

    # Retrieve all curation items in a set
    #
    # @example
    #   client.curation_sets['my-set'].items.retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Access an individual curation item by ID within this curation set.
    #
    # @example
    #   client.curation_sets['my-set'].items['promote-hat'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    #
    # @return [CurationSetItem]
    def [](item_id)
      @items[item_id] ||= CurationSetItem.new(@curation_set_name, item_id, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{CurationSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@curation_set_name)}/items#{"/#{operation}" unless operation.nil?}"
    end
  end
end
