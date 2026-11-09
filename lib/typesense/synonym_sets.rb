# frozen_string_literal: true

module Typesense
  class SynonymSets
    RESOURCE_PATH = '/synonym_sets'

    def initialize(api_call)
      @api_call = api_call
      @synonym_sets = {}
    end

    # Create or update a synonym set with the given name
    #
    # @example
    #   client.synonym_sets.upsert('my-set', 'items' => [{ 'id' => 'syn-1', 'synonyms' => ['nyc', 'new york'] }])
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    def upsert(synonym_set_name, params)
      @api_call.put(endpoint_path(synonym_set_name), params)
    end

    # Retrieve all synonym sets
    #
    # @example
    #   client.synonym_sets.retrieve
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Access an individual synonym set by name.
    #
    # @example
    #   client.synonym_sets['my-set'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    #
    # @return [SynonymSet]
    def [](synonym_set_name)
      @synonym_sets[synonym_set_name] ||= SynonymSet.new(synonym_set_name, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{RESOURCE_PATH}#{"/#{URI.encode_www_form_component(operation)}" unless operation.nil?}"
    end
  end
end
