# frozen_string_literal: true

module Typesense
  class Collections
    RESOURCE_PATH = '/collections'

    def initialize(configuration)
      @configuration = configuration
      @collections   = {}
    end

    def create(schema)
      ApiCall.new(@configuration).post(RESOURCE_PATH, schema)
    end

    def retrieve_all
      ApiCall.new(@configuration).get(RESOURCE_PATH)
    end

    def [](collection_name)
      @collections[collection_name] ||= Collection.new(@configuration, collection_name)
    end
  end
end
