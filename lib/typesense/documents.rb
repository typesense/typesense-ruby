# frozen_string_literal: true

module Typesense
  class Documents
    RESOURCE_PATH = '/documents'

    def initialize(collection_name, api_call)
      @collection_name = collection_name
      @api_call        = api_call
      @documents       = {}
    end

    def create(document)
      @api_call.post(endpoint_path, document)
    end

    def create_many(documents)
      documents_in_jsonl_format = documents.map { |document| JSON.dump(document) }.join("\n")
      @api_call.post(endpoint_path('import'), as_json: false, body: documents_in_jsonl_format)
    end

    def export
      (@api_call.get(endpoint_path('export')) || '').split("\n")
    end

    def search(search_parameters)
      @api_call.get(endpoint_path('search'), search_parameters)
    end

    def [](document_id)
      @documents[document_id] ||= Document.new(@collection_name, document_id, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{Collections::RESOURCE_PATH}/#{@collection_name}#{Documents::RESOURCE_PATH}#{operation.nil? ? '' : '/' + operation}"
    end
  end
end
