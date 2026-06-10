# frozen_string_literal: true

module Typesense
  class CurationSetItem
    def initialize(curation_set_name, item_id, api_call)
      @curation_set_name = curation_set_name
      @item_id = item_id
      @api_call = api_call
    end

    # Retrieve a specific curation item by its id
    #
    # @example
    #   client.curation_sets['my-set'].items['promote-hat'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Create or update a curation set item with the given id
    #
    # @example
    #   client.curation_sets['my-set'].items['promote-hat'].upsert('rule' => { 'query' => 'hat', 'match' => 'exact' }, 'includes' => [])
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def upsert(params)
      @api_call.put(endpoint_path, params)
    end

    # Delete a specific curation item by its id
    #
    # @example
    #   client.curation_sets['my-set'].items['promote-hat'].delete
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{CurationSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@curation_set_name)}/items/#{URI.encode_www_form_component(@item_id)}"
    end
  end
end
