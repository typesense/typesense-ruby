module Typesense
  class Documents
    class << self
      def create(collection_name, document)
        ApiCall.new.post(Collections.documents_path_for(collection_name), document)
      end

      def retrieve(collection_name, document_id)
        ApiCall.new.get("#{Collections.documents_path_for(collection_name)}/#{document_id}")
      end

      def delete(collection_name, document_id)
        ApiCall.new.delete("#{Collections.documents_path_for(collection_name)}/#{document_id}")
      end

      def export(collection_name)
        api_response = ApiCall.new.get_unparsed_response("#{Collections.documents_path_for(collection_name)}/export")

        api_response.split("\n")
      end

      def search(collection_name, search_parameters)
        ApiCall.new.get("#{Collections.documents_path_for(collection_name)}/search", search_parameters)
      end
    end
  end
end