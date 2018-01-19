module Typesense
  class Collections
    ENDPOINT_PATH = '/collections'

    def self.create(schema)
      ApiCall.new.post(ENDPOINT_PATH, schema)
    end

    def self.retrieve(collection_name)
      ApiCall.new.get("#{ENDPOINT_PATH}/#{collection_name}")
    end

    def self.delete(collection_name)
      ApiCall.new.delete("#{ENDPOINT_PATH}/#{collection_name}")
    end

    def self.retrieve_all
      ApiCall.new.get("#{ENDPOINT_PATH}")
    end

    def self.documents_path_for(collection_name)
      "#{ENDPOINT_PATH}/#{collection_name}/documents"
    end
  end
end