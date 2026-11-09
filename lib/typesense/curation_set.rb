# frozen_string_literal: true

module Typesense
  class CurationSet
    # Access the items in this curation set. Use it to list items, or as an array
    # to access a single item by ID.
    #
    # @example
    #   client.curation_sets['my-set'].items.retrieve
    # @example
    #   client.curation_sets['my-set'].items['promote-hat'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    #
    # @return [CurationSetItems]
    attr_reader :items

    def initialize(curation_set_name, api_call)
      @curation_set_name = curation_set_name
      @api_call = api_call
      @items = CurationSetItems.new(@curation_set_name, @api_call)
    end

    # Create or update a curation set with the given name
    #
    # @example
    #   client.curation_sets['my-set'].upsert('items' => [{ 'id' => 'promote-hat', 'rule' => { 'query' => 'hat', 'match' => 'exact' } }])
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def upsert(curation_set_data)
      @api_call.put(endpoint_path, curation_set_data)
    end

    # Retrieve a specific curation set by its name
    #
    # @example
    #   client.curation_sets['my-set'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Delete a specific curation set by its name
    #
    # @example
    #   client.curation_sets['my-set'].delete
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{CurationSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@curation_set_name)}"
    end
  end
end
