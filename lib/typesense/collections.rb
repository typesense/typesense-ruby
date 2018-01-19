module Typesense
  class Collections
    ENDPOINT_PATH = '/collections'

    class << self
      def create(schema)
        ApiCall.new.post(ENDPOINT_PATH, schema)
      end

      def retrieve(collection_name)
        ApiCall.new.get("#{ENDPOINT_PATH}/#{collection_name}")
      end

      def delete(collection_name)
        ApiCall.new.delete("#{ENDPOINT_PATH}/#{collection_name}")
      end

      def retrieve_all
        ApiCall.new.get("#{ENDPOINT_PATH}")
      end

      def documents_path_for(collection_name)
        "#{ENDPOINT_PATH}/#{collection_name}/documents"
      end
    end
  end
end