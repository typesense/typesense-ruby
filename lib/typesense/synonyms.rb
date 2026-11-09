# frozen_string_literal: true

module Typesense
  # @deprecated Deprecated starting with Typesense Server v30. Please migrate to `client.synonym_sets` (new Synonym Sets APIs).
  class Synonyms
    RESOURCE_PATH = '/synonyms'

    def initialize(collection_name, api_call)
      @collection_name = collection_name
      @api_call        = api_call
      @synonyms = {}
    end

    # Create or update a synonym (legacy v1) on this collection.
    #
    # @example
    #   client.collections['products'].synonyms.upsert('syn-1', 'synonyms' => ['nyc', 'new york'])
    #
    # @see https://typesense.org/docs/29.0/api/synonyms.html
    def upsert(synonym_id, params)
      @api_call.put(endpoint_path(synonym_id), params)
    end

    # Retrieve all synonyms (legacy v1) on this collection.
    #
    # @example
    #   client.collections['products'].synonyms.retrieve
    #
    # @see https://typesense.org/docs/29.0/api/synonyms.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Access an individual synonym by ID within this collection.
    #
    # @example
    #   client.collections['products'].synonyms['syn-1'].retrieve
    #
    # @see https://typesense.org/docs/29.0/api/synonyms.html
    #
    # @return [Synonym]
    def [](synonym_id)
      @synonyms[synonym_id] ||= Synonym.new(@collection_name, synonym_id, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{Collections::RESOURCE_PATH}/#{URI.encode_www_form_component(@collection_name)}#{Synonyms::RESOURCE_PATH}#{"/#{URI.encode_www_form_component(operation)}" unless operation.nil?}"
    end
  end
end
