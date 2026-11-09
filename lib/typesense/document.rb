# frozen_string_literal: true

module Typesense
  class Document
    def initialize(collection_name, document_id, api_call)
      @collection_name = collection_name
      @document_id     = document_id
      @api_call        = api_call
    end

    # Fetch an individual document from a collection by using its ID.
    #
    # @example
    #   client.collections['products'].documents['1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/documents.html#retrieve-a-document
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Delete an individual document from a collection by using its ID.
    #
    # @example
    #   client.collections['products'].documents['1'].delete
    #
    # @see https://typesense.org/docs/latest/api/documents.html#delete-a-document
    def delete
      @api_call.delete(endpoint_path)
    end

    # Update an individual document by ID by merging the provided fields.
    #
    # @example
    #   client.collections['products'].documents['1'].update('in_stock' => true)
    #
    # @see https://typesense.org/docs/latest/api/documents.html#update-a-document
    def update(partial_document, options = {})
      @api_call.patch(endpoint_path, partial_document, options)
    end

    private

    def endpoint_path
      "#{Collections::RESOURCE_PATH}/#{URI.encode_www_form_component(@collection_name)}#{Documents::RESOURCE_PATH}/#{URI.encode_www_form_component(@document_id)}"
    end
  end
end
