# frozen_string_literal: true

module Typesense
  class Documents
    RESOURCE_PATH = '/documents'

    def initialize(configuration, collection_name)
      @configuration   = configuration
      @collection_name = collection_name
      @documents       = {}
    end

    def create(document)
      ApiCall.new(@configuration).post(endpoint_path, document)
    end

    def export
      ApiCall.new(@configuration).get_unparsed_response(endpoint_path('export')).split("\n")
    end

    def search(search_parameters)
      ApiCall.new(@configuration).get(endpoint_path('search'), search_parameters)
    end

    def [](document_id)
      @documents[document_id] ||= Document.new(@configuration, @collection_name, document_id)
    end

    private

    def endpoint_path(operation = nil)
      "#{Collections::RESOURCE_PATH}/#{@collection_name}#{Documents::RESOURCE_PATH}#{operation.nil? ? '' : '/' + operation}"
    end
  end
end
