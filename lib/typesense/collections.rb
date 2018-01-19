module Typesense
  class Collections
    ENDPOINT_PATH = '/collections'

    def self.create(schema)
      ApiCall.new.post(ENDPOINT_PATH, schema)
    end

    def self.retrieve(collection_name)
      ApiCall.new.get("#{ENDPOINT_PATH}/#{collection_name}")
    end

    def self.retrieve_all
      ApiCall.new.get("#{ENDPOINT_PATH}")
    end
  end
end