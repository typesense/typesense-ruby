# frozen_string_literal: true

module Typesense
  # @deprecated Deprecated starting with Typesense Server v30. Please migrate to `client.synonym_sets` (new Synonym Sets APIs).
  class Synonym
    def initialize(collection_name, synonym_id, api_call)
      @collection_name = collection_name
      @synonym_id = synonym_id
      @api_call = api_call
    end

    # Retrieve a synonym (legacy v1) by ID on this collection.
    #
    # @example
    #   client.collections['products'].synonyms['syn-1'].retrieve
    #
    # @see https://typesense.org/docs/29.0/api/synonyms.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Delete a synonym (legacy v1) by ID on this collection.
    #
    # @example
    #   client.collections['products'].synonyms['syn-1'].delete
    #
    # @see https://typesense.org/docs/29.0/api/synonyms.html
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Collections::RESOURCE_PATH}/#{URI.encode_www_form_component(@collection_name)}#{Synonyms::RESOURCE_PATH}/#{URI.encode_www_form_component(@synonym_id)}"
    end
  end
end
