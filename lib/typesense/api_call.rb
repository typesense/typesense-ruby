require 'httparty'

module Typesense
  class ApiCall
    include HTTParty

    API_KEY_HEADER_NAME = 'X-TYPESENSE-API-KEY'

    def post(endpoint, parameters = {})
      perform_http_call_with_error_handling do
        self.class.post(self.class.uri_for(endpoint),
                        default_options.merge(
                            body:    parameters.to_json,
                            headers: default_headers.merge('Content-Type' => 'application/json')
                        )
        )
      end.parsed_response
    end

    def get(endpoint, parameters = {})
      get_unparsed_response(endpoint, parameters).parsed_response
    end

    def get_unparsed_response(endpoint, parameters = {})
      perform_http_call_with_error_handling do
        self.class.get(self.class.uri_for(endpoint),
                       default_options.merge(
                           query:   parameters,
                           headers: default_headers
                       )
        )
      end
    end

    def delete(endpoint, parameters = {})
      perform_http_call_with_error_handling do
        self.class.delete(self.class.uri_for(endpoint),
                          default_options.merge(
                              query:   parameters,
                              headers: default_headers
                          )
        )
      end.parsed_response
    end

    private
    def self.uri_for(endpoint)
      "#{Typesense.configuration.master_node[:protocol]}://#{Typesense.configuration.master_node[:host]}:#{Typesense.configuration.master_node[:port]}#{endpoint}"
    end

    def perform_http_call_with_error_handling
      if Typesense.configuration.nil? ||
          Typesense.configuration.master_node.nil? ||
          %i(protocol host port api_key).any? { |attr| Typesense.configuration.master_node.send(:[], attr).nil? }
        raise Error::MissingConfiguration.new('Missing required configuration. Use `Typsense.configure to set master_node[:protocol], master_node[:host], master_node[:port] and master_node[:api_key].')
      end

      if !Typesense.configuration.read_replica_nodes.nil? &&
          Typesense.configuration.read_replica_nodes.map { |node| [node[:protocol], node[:host], node[:port], node[:api_key]] }.flatten.include?(nil)
        raise Error::MissingConfiguration.new('Missing required configuration for read_replica_nodes. Use `Typsense.configure to set read_replica_nodes[][:protocol], read_replica_nodes[][:host], read_replica_nodes[][:port] and read_replica_nodes[][:api_key].')
      end

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

    def default_options
      {
          timeout: Typesense.configuration.timeout
      }
    end

    def default_headers
      {
          "#{API_KEY_HEADER_NAME}" => Typesense.configuration.master_node[:api_key]
      }
    end
  end
end