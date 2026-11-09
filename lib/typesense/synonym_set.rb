# frozen_string_literal: true

module Typesense
  class SynonymSet
    def initialize(synonym_set_name, api_call)
      @synonym_set_name = synonym_set_name
      @api_call = api_call
    end

    # Create or update a synonym set with the given name
    #
    # @example
    #   client.synonym_sets['my-set'].upsert('items' => [{ 'id' => 'syn-1', 'synonyms' => ['nyc', 'new york'] }])
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    def upsert(params)
      @api_call.put(endpoint_path, params)
    end

    # Retrieve a specific synonym set by its name
    #
    # @example
    #   client.synonym_sets['my-set'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Delete a specific synonym set by its name
    #
    # @example
    #   client.synonym_sets['my-set'].delete
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{SynonymSets::RESOURCE_PATH}/#{URI.encode_www_form_component(@synonym_set_name)}"
    end
  end
end
