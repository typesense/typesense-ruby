# frozen_string_literal: true

module Typesense
  class SynonymSetItem
    def initialize(synonym_set_name, item_id, api_call)
      @synonym_set_name = synonym_set_name
      @item_id = item_id
      @api_call = api_call
    end

    # Retrieve a specific synonym item by its id
    #
    # @example
    #   client.synonym_sets['my-set'].items['smart-phone-synonyms'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Create or update a synonym item with the given id
    #
    # @example
    #   client.synonym_sets['my-set'].items['smart-phone-synonyms'].upsert('synonyms' => ['smart phone', 'iphone'])
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    def upsert(params)
      @api_call.put(endpoint_path, params)
    end

    # Delete a specific synonym item by its id
    #
    # @example
    #   client.synonym_sets['my-set'].items['smart-phone-synonyms'].delete
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{SynonymSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@synonym_set_name)}/items/#{URI.encode_www_form_component(@item_id)}"
    end
  end
end
