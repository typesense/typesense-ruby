# frozen_string_literal: true

require 'base64'
require 'json'
require 'openssl'

module Typesense
  class Keys
    RESOURCE_PATH = '/keys'

    def initialize(api_call)
      @api_call = api_call
      @keys = {}
    end

    # Create an API Key with fine-grain access control. You can restrict access on both a per-collection and per-action level. The generated key is returned only during creation. You want to store this key carefully in a secure place.
    #
    # @example
    #   client.keys.create('description' => 'Search-only key', 'actions' => ['documents:search'], 'collections' => ['*'])
    #
    # @see https://typesense.org/docs/latest/api/api-keys.html#create-an-api-key
    def create(parameters)
      @api_call.post(RESOURCE_PATH, parameters)
    end

    # Retrieve (metadata about) all keys.
    #
    # @example
    #   client.keys.retrieve
    #
    # @see https://typesense.org/docs/latest/api/api-keys.html#list-all-keys
    def retrieve
      @api_call.get(RESOURCE_PATH)
    end

    # Generate a scoped search-only API key with embedded parameters such as `filter_by` or `expires_at`.
    #
    # @example
    #   client.keys.generate_scoped_search_key('search-only-key', 'filter_by' => 'company_id:124', 'expires_at' => 1700000000)
    #
    # @see https://typesense.org/docs/latest/api/api-keys.html#generate-scoped-search-key
    def generate_scoped_search_key(search_key, parameters)
      parameters_json = JSON.dump(parameters)
      digest = Base64.encode64(OpenSSL::HMAC.digest('sha256', search_key, parameters_json)).gsub("\n", '')
      key_prefix = search_key[0...4]
      raw_scoped_key = "#{digest}#{key_prefix}#{parameters_json}"
      Base64.encode64(raw_scoped_key).gsub("\n", '')
    end

    # Access an individual API key by ID.
    #
    # @example
    #   client.keys[1].retrieve
    #
    # @see https://typesense.org/docs/latest/api/api-keys.html
    #
    # @return [Key]
    def [](id)
      @keys[id] ||= Key.new(id, @api_call)
    end
  end
end
