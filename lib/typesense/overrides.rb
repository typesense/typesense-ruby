# frozen_string_literal: true

module Typesense
  class Overrides
    RESOURCE_PATH = '/overrides'

    def initialize(collection_name, api_call)
      @collection_name = collection_name
      @api_call        = api_call
      @overrides       = {}
    end

    # Create or update an override (curation rule) on this collection.
    #
    # @example
    #   client.collections['products'].overrides.upsert('promote-hat', 'rule' => { 'query' => 'hat', 'match' => 'exact' }, 'includes' => [])
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def upsert(override_id, params)
      @api_call.put(endpoint_path(override_id), params)
    end

    # Retrieve all overrides (curation rules) on this collection.
    #
    # @example
    #   client.collections['products'].overrides.retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Access an individual override by ID within this collection.
    #
    # @example
    #   client.collections['products'].overrides['promote-hat'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    #
    # @return [Override]
    def [](override_id)
      @overrides[override_id] ||= Override.new(@collection_name, override_id, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{Collections::RESOURCE_PATH}/#{URI.encode_www_form_component(@collection_name)}#{Overrides::RESOURCE_PATH}#{"/#{URI.encode_www_form_component(operation)}" unless operation.nil?}"
    end
  end
end
