# frozen_string_literal: true

require 'json'

module Typesense
  class Documents
    RESOURCE_PATH = '/documents'

    def initialize(collection_name, api_call)
      @collection_name = collection_name
      @api_call        = api_call
      @documents       = {}
    end

    # Index a single document. The document must conform to the schema of the collection.
    #
    # @example
    #   client.collections['products'].documents.create('id' => '1', 'title' => 'Hat')
    #
    # @see https://typesense.org/docs/latest/api/documents.html#index-a-single-document
    def create(document, options = {})
      @api_call.post(endpoint_path, document, options)
    end

    # Upsert a single document. Creates the document if it does not exist, otherwise updates it.
    #
    # @example
    #   client.collections['products'].documents.upsert('id' => '1', 'title' => 'Hat')
    #
    # @see https://typesense.org/docs/latest/api/documents.html#upsert
    def upsert(document, options = {})
      @api_call.post(endpoint_path, document, options.merge(action: :upsert))
    end

    # Update documents matching a `filter_by` condition, or update a single document with `action: "update"` semantics.
    #
    # @example
    #   client.collections['products'].documents.update({ 'in_stock' => true }, filter_by: 'category:=hats')
    # @example
    #   client.collections['products'].documents.update('id' => '1', 'title' => 'Hat')
    #
    # @see https://typesense.org/docs/latest/api/documents.html#update-documents-with-conditional-query
    def update(document, options = {})
      if options['filter_by'] || options[:filter_by]
        @api_call.patch(endpoint_path, document, options)
      else
        @api_call.post(endpoint_path, document, options.merge(action: :update))
      end
    end

    # @deprecated Use {#import} instead, which accepts both an array of documents or a JSONL string.
    def create_many(documents, options = {})
      @api_call.logger.warn('#create_many is deprecated and will be removed in a future version. Use #import instead, which now takes both an array of documents or a JSONL string of documents')
      import(documents, options)
    end

    # Import documents into a collection. Accepts a JSONL string or an array of document hashes.
    #
    # @example
    #   client.collections['products'].documents.import([{ 'id' => '1', 'title' => 'Hat' }, { 'id' => '2', 'title' => 'Shirt' }])
    # @example
    #   client.collections['products'].documents.import(jsonl_string)
    #
    # @see https://typesense.org/docs/latest/api/documents.html#index-multiple-documents
    #
    # @param [Array,String] documents An array of document hashes or a JSONL string of documents.
    def import(documents, options = {})
      documents_in_jsonl_format = if documents.is_a?(Array)
                                    documents.map { |document| JSON.dump(document) }.join("\n")
                                  else
                                    documents
                                  end

      results_in_jsonl_format = @api_call.perform_request(
        'post',
        endpoint_path('import'),
        query_parameters: options,
        body_parameters: documents_in_jsonl_format,
        additional_headers: { 'Content-Type' => 'text/plain' }
      )

      if documents.is_a?(Array)
        results_in_jsonl_format.split("\n").map do |r|
          JSON.parse(r)
        rescue JSON::ParserError => e
          {
            'success' => false,
            'exception' => e.class.name,
            'error' => e.message,
            'json' => r
          }
        end
      else
        results_in_jsonl_format
      end
    end

    # Export all documents in a collection as a JSONL string.
    #
    # @example
    #   client.collections['products'].documents.export
    #
    # @see https://typesense.org/docs/latest/api/documents.html#export-documents
    def export(options = {})
      @api_call.get(endpoint_path('export'), options)
    end

    # Search for documents in a collection that match the search criteria.
    #
    # @example
    #   client.collections['products'].documents.search('q' => '*', 'query_by' => 'title')
    #
    # @see https://typesense.org/docs/latest/api/search.html
    def search(search_parameters)
      @api_call.get(endpoint_path('search'), search_parameters)
    end

    # Access an individual document by ID within this collection.
    #
    # @example
    #   client.collections['products'].documents['1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/documents.html
    #
    # @return [Document]
    def [](document_id)
      @documents[document_id] ||= Document.new(@collection_name, document_id, @api_call)
    end

    # Delete a bunch of documents that match a specific filter condition.
    #
    # @example
    #   client.collections['products'].documents.delete(filter_by: 'in_stock:=false')
    #
    # @see https://typesense.org/docs/latest/api/documents.html#delete-by-query
    def delete(query_parameters = {})
      @api_call.delete(endpoint_path, query_parameters)
    end

    # Truncate all documents in the collection.
    #
    # @example
    #   client.collections['products'].documents.truncate
    #
    # @see https://typesense.org/docs/latest/api/documents.html#delete-by-query
    def truncate
      @api_call.delete(endpoint_path, { truncate: true })
    end

    private

    def endpoint_path(operation = nil)
      "#{Collections::RESOURCE_PATH}/#{URI.encode_www_form_component(@collection_name)}#{Documents::RESOURCE_PATH}#{"/#{operation}" unless operation.nil?}"
    end
  end
end
