# frozen_string_literal: true

module Typesense
  class Collections
    RESOURCE_PATH = '/collections'

    def initialize(api_call)
      @api_call    = api_call
      @collections = {}
    end

    def create(schema)
      @api_call.post(RESOURCE_PATH, schema)
    end

    def retrieve(options = {})
      @api_call.get(RESOURCE_PATH, options)
    end

    def [](collection_name)
      @collections[collection_name] ||= Collection.new(collection_name, @api_call)
    end
  end
end
