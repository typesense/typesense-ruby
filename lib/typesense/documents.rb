# frozen_string_literal: true

require 'oj'

module Typesense
  class Documents
    RESOURCE_PATH = '/documents'

    def initialize(collection_name, api_call)
      @collection_name = collection_name
      @api_call        = api_call
      @documents       = {}
    end

    def create(document, options = {})
      @api_call.post(endpoint_path, document, options)
    end

    def create_many(documents, options = {})
      documents_in_jsonl_format = documents.map { |document| Oj.dump(document) }.join("\n")
      results_in_jsonl_format = import(documents_in_jsonl_format, options)
      results_in_jsonl_format.split("\n").map { |r| Oj.load(r) }
    end

    def import(documents_in_jsonl_format, options = {})
      @api_call.perform_request(
        'post',
        endpoint_path('import'),
        query_parameters: options,
        body_parameters: documents_in_jsonl_format,
        additional_headers: { 'Content-Type' => 'text/plain' }
      )
    end

    def export
      @api_call.get(endpoint_path('export'))
    end

    def search(search_parameters)
      @api_call.get(endpoint_path('search'), search_parameters)
    end

    def [](document_id)
      @documents[document_id] ||= Document.new(@collection_name, document_id, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{Collections::RESOURCE_PATH}/#{@collection_name}#{Documents::RESOURCE_PATH}#{operation.nil? ? '' : "/#{operation}"}"
    end
  end
end
