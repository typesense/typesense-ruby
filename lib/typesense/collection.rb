# frozen_string_literal: true

module Typesense
  class Collection
    # Access the documents resource for this collection. Use it to list, index, search, import, or export documents,
    # or as an array to access a single document by ID.
    #
    # @example
    #   client.collections['products'].documents.create('id' => '1', 'title' => 'Hat')
    # @example
    #   client.collections['products'].documents['1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/documents.html
    #
    # @return [Documents]
    attr_reader :documents

    # Access the legacy overrides (curation) resource for this collection. Use it to list or upsert overrides,
    # or as an array to access a single override by ID.
    #
    # @example
    #   client.collections['products'].overrides.upsert('promote-hat', 'rule' => { 'query' => 'hat', 'match' => 'exact' }, 'includes' => [])
    # @example
    #   client.collections['products'].overrides['promote-hat'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    #
    # @return [Overrides]
    attr_reader :overrides

    # Access the legacy synonyms resource for this collection. Use it to list or upsert synonyms,
    # or as an array to access a single synonym by ID.
    #
    # @example
    #   client.collections['products'].synonyms.upsert('syn-1', 'synonyms' => ['nyc', 'new york'])
    # @example
    #   client.collections['products'].synonyms['syn-1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    #
    # @return [Synonyms]
    attr_reader :synonyms

    def initialize(name, api_call)
      @name      = name
      @api_call  = api_call
      @documents = Documents.new(@name, @api_call)
      @overrides = Overrides.new(@name, @api_call)
      @synonyms  = Synonyms.new(@name, @api_call)
    end

    # Retrieve the details of a collection, given its name.
    #
    # @example
    #   client.collections['products'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/collections.html#retrieve-a-collection
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Update a collection's schema to modify the fields and their types.
    #
    # @example
    #   client.collections['products'].update('fields' => [{ 'name' => 'tags', 'type' => 'string[]' }])
    #
    # @see https://typesense.org/docs/latest/api/collections.html#update-or-alter-a-collection
    def update(update_schema)
      @api_call.patch(endpoint_path, update_schema)
    end

    # Permanently drops a collection. This action cannot be undone. For large collections, this might have an impact on read latencies.
    #
    # @example
    #   client.collections['products'].delete
    #
    # @see https://typesense.org/docs/latest/api/collections.html#drop-a-collection
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Collections::RESOURCE_PATH}/#{URI.encode_www_form_component(@name)}"
    end
  end
end
