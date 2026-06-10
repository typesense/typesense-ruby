# frozen_string_literal: true

module Typesense
  class Aliases
    RESOURCE_PATH = '/aliases'

    def initialize(api_call)
      @api_call = api_call
      @aliases = {}
    end

    # Create or update a collection alias.
    #
    # @example
    #   client.aliases.upsert('my-alias', 'collection_name' => 'products')
    #
    # @see https://typesense.org/docs/latest/api/collection-alias.html#create-or-update-an-alias
    def upsert(alias_name, mapping)
      @api_call.put(endpoint_path(alias_name), mapping)
    end

    # List all aliases and the corresponding collections that they map to.
    #
    # @example
    #   client.aliases.retrieve
    #
    # @see https://typesense.org/docs/latest/api/collection-alias.html#list-all-aliases
    def retrieve
      @api_call.get(RESOURCE_PATH)
    end

    # Access an individual collection alias by name.
    #
    # @example
    #   client.aliases['my-alias'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/collection-alias.html
    #
    # @return [Alias]
    def [](alias_name)
      @aliases[alias_name] ||= Alias.new(alias_name, @api_call)
    end

    private

    def endpoint_path(alias_name)
      "#{Aliases::RESOURCE_PATH}/#{URI.encode_www_form_component(alias_name)}"
    end
  end
end
