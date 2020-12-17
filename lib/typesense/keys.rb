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

    def create(parameters)
      @api_call.post(RESOURCE_PATH, parameters)
    end

    def retrieve
      @api_call.get(RESOURCE_PATH)
    end

    def generate_scoped_search_key(search_key, parameters)
      parameters_json = JSON.dump(parameters)
      digest = Base64.encode64(OpenSSL::HMAC.digest('sha256', search_key, parameters_json)).gsub("\n", '')
      key_prefix = search_key[0...4]
      raw_scoped_key = "#{digest}#{key_prefix}#{parameters_json}"
      Base64.encode64(raw_scoped_key).gsub("\n", '')
    end

    def [](id)
      @keys[id] ||= Key.new(id, @api_call)
    end
  end
end
