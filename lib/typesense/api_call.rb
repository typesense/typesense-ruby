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
                          'Content-Type'           => 'application/json'
                      }).parsed_response
    end

    def get(endpoint, parameters = {})
      get_unparsed_response(endpoint, parameters).parsed_response
    end

    def get_unparsed_response(endpoint, parameters = {})
      self.class.get(self.class.uri_for(endpoint),
                     query:   parameters,
                     headers: {
                         "#{API_KEY_HEADER_NAME}" => Typesense.configuration.api_key
                     })
    end

    def delete(endpoint, parameters = {})
      self.class.delete(self.class.uri_for(endpoint),
                        query:   parameters,
                        headers: {
                            "#{API_KEY_HEADER_NAME}" => Typesense.configuration.api_key
                        }).parsed_response
    end

    private
    def self.uri_for(endpoint)
      "#{Typesense.configuration.protocol}://#{Typesense.configuration.host}#{endpoint}"
    end
  end
end