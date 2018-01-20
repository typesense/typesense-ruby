require 'httparty'

module Typesense
  class ApiCall
    include HTTParty

    API_KEY_HEADER_NAME = 'X-TYPESENSE-API-KEY'

    def post(endpoint, parameters = {})
      perform_api_call_with_error_handling do
        self.class.post(self.class.uri_for(endpoint),
                        body:    parameters.to_json,
                        headers: {
                            "#{API_KEY_HEADER_NAME}" => Typesense.configuration.api_key,
                            'Content-Type'           => 'application/json'
                        })
      end.parsed_response
    end

    def get(endpoint, parameters = {})
      get_unparsed_response(endpoint, parameters).parsed_response
    end

    def get_unparsed_response(endpoint, parameters = {})
      perform_api_call_with_error_handling do
        self.class.get(self.class.uri_for(endpoint),
                       query:   parameters,
                       headers: {
                           "#{API_KEY_HEADER_NAME}" => Typesense.configuration.api_key
                       })
      end
    end

    def delete(endpoint, parameters = {})
      perform_api_call_with_error_handling do
        self.class.delete(self.class.uri_for(endpoint),
                          query:   parameters,
                          headers: {
                              "#{API_KEY_HEADER_NAME}" => Typesense.configuration.api_key
                          })
      end.parsed_response
    end

    private
    def self.uri_for(endpoint)
      "#{Typesense.configuration.protocol}://#{Typesense.configuration.host}:#{Typesense.configuration.port}#{endpoint}"
    end

    def perform_api_call_with_error_handling
      response_object = yield

      return response_object if response_object.response.code_type <= Net::HTTPSuccess # 2xx

      error_klass = if response_object.response.code_type <= Net::HTTPBadRequest # 400
                      Error::RequestMalformed
                    elsif response_object.response.code_type <= Net::HTTPUnauthorized # 401
                      Error::RequestUnauthorized
                    elsif response_object.response.code_type <= Net::HTTPNotFound # 404
                      Error::ObjectNotFound
                    elsif response_object.response.code_type <= Net::HTTPConflict # 409
                      Error::ObjectAlreadyExists
                    elsif response_object.response.code_type <= Net::HTTPUnprocessableEntity # 422
                      Error::ObjectUnprocessable
                    elsif response_object.response.code_type <= Net::HTTPServerError # 5xx
                      Error::ServerError
                    else
                      Error
                    end

      raise error_klass.new(response_object.parsed_response['message'])
    end
  end
end