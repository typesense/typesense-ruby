# frozen_string_literal: true

module Typesense
  class SynonymSetItems
    def initialize(synonym_set_name, api_call)
      @synonym_set_name = synonym_set_name
      @api_call = api_call
      @items = {}
    end

    # Retrieve all synonym items in a set
    #
    # @example
    #   client.synonym_sets['my-set'].items.retrieve
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Access an individual synonym item by ID within this synonym set.
    #
    # @example
    #   client.synonym_sets['my-set'].items['smart-phone-synonyms'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    #
    # @return [SynonymSetItem]
    def [](item_id)
      @items[item_id] ||= SynonymSetItem.new(@synonym_set_name, item_id, @api_call)
    end

    private

    def endpoint_path
      "#{SynonymSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@synonym_set_name)}/items"
    end
  end
end
