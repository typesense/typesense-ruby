# frozen_string_literal: true

module Typesense
  class Collections
    RESOURCE_PATH = '/collections'

    def initialize(api_call)
      @api_call    = api_call
      @collections = {}
    end

    # When a collection is created, we give it a name and describe the fields that will be indexed from the documents added to the collection.
    #
    # @example
    #   client.collections.create('name' => 'products', 'fields' => [{ 'name' => 'title', 'type' => 'string' }])
    #
    # @see https://typesense.org/docs/latest/api/collections.html#create-a-collection
    def create(schema)
      @api_call.post(RESOURCE_PATH, schema)
    end

    # Returns a summary of all your collections. The collections are returned sorted by creation date, with the most recent collections appearing first.
    #
    # @example
    #   client.collections.retrieve
    #
    # @see https://typesense.org/docs/latest/api/collections.html#list-all-collections
    def retrieve(options = {})
      @api_call.get(RESOURCE_PATH, options)
    end

    # Access an individual collection by name.
    #
    # @example
    #   client.collections['products'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/collections.html
    #
    # @return [Collection]
    def [](collection_name)
      @collections[collection_name] ||= Collection.new(collection_name, @api_call)
    end
  end
end
