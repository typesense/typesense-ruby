# frozen_string_literal: true

module Typesense
  class Document
    def initialize(configuration, collection_name, document_id)
      @configuration   = configuration
      @collection_name = collection_name
      @document_id     = document_id
    end

    def retrieve
      ApiCall.new(@configuration).get(endpoint_path)
    end

    def delete
      ApiCall.new(@configuration).delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Collections::RESOURCE_PATH}/#{@collection_name}#{Documents::RESOURCE_PATH}/#{@document_id}"
    end
  end
end
