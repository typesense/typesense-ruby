require 'httparty'

module Typesense
  class ApiCall
    include HTTParty

    API_KEY_HEADER_NAME = 'X-TYPESENSE-API-KEY'

    def post(endpoint, parameters = {})
      self.class.post(self.class.uri_for(endpoint),
                      body:    parameters.to_json,
                      headers: {
                          "#{API_KEY_HEADER_NAME}" => Typesense.configuration.api_key,
                          'Content-Type' => 'application/json'
                      }).parsed_response
    end

    private
    def self.uri_for(endpoint)
      "#{Typesense.configuration.protocol}://#{Typesense.configuration.host}#{endpoint}"
    end
  end
end