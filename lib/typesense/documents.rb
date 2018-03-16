module Typesense
  class Documents
    def initialize(configuration, collection_name, document_id = nil)
      @configuration   = configuration
      @collection_name = collection_name
      @document_id     = document_id
    end

    def create(document)
      validate_absence_of_document_id! __method__
      ApiCall.new(@configuration).post(endpoint_path, document)
    end

    def retrieve
      ApiCall.new(@configuration).get("#{endpoint_path}/#{@document_id}")
    end

    def delete
      ApiCall.new(@configuration).delete("#{endpoint_path}/#{@document_id}")
    end

    def export
      validate_absence_of_document_id! __method__

      api_response = ApiCall.new(@configuration).get_unparsed_response("#{endpoint_path}/export")

      api_response.split("\n")
    end

    def search(search_parameters)
      validate_absence_of_document_id! __method__

      ApiCall.new(@configuration).get("#{endpoint_path}/search", search_parameters)
    end

    private
    def endpoint_path
      "#{Collections::ENDPOINT_PATH}/#{@collection_name}/documents"
    end

    def validate_absence_of_document_id!(method)
      if !@document_id.nil?
        raise Error::NoMethodError.new("#{method} cannot be called on a specific document")
      end
    end
  end
end