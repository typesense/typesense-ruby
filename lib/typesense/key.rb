# frozen_string_literal: true

module Typesense
  class Key
    def initialize(id, api_call)
      @id = id
      @api_call = api_call
    end

    # Retrieve (metadata about) a key. Only the key prefix is returned when you retrieve a key. Due to security reasons, only the create endpoint returns the full API key.
    #
    # @example
    #   client.keys[1].retrieve
    #
    # @see https://typesense.org/docs/latest/api/api-keys.html#retrieve-an-api-key
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Delete an API key given its ID.
    #
    # @example
    #   client.keys[1].delete
    #
    # @see https://typesense.org/docs/latest/api/api-keys.html#delete-api-key
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Keys::RESOURCE_PATH}/#{URI.encode_www_form_component(@id)}"
    end
  end
end
