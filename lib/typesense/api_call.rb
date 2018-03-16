require 'httparty'

module Typesense
  class ApiCall
    include HTTParty

    API_KEY_HEADER_NAME = 'X-TYPESENSE-API-KEY'

    def initialize(configuration)
      @configuration = configuration
    end

    def post(endpoint, parameters = {})
      perform_http_call_with_error_handling(:do_not_use_read_replicas) do
        self.class.post(uri_for(endpoint),
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
      perform_http_call_with_error_handling(:use_read_replicas) do |node, node_index|
        self.class.get(uri_for(endpoint, node, node_index),
                       default_options.merge(
                           query:   parameters,
                           headers: default_headers
                       )
        )
      end
    end

    def delete(endpoint, parameters = {})
      perform_http_call_with_error_handling(:do_not_use_read_replicas) do
        self.class.delete(uri_for(endpoint),
                          default_options.merge(
                              query:   parameters,
                              headers: default_headers
                          )
        )
      end.parsed_response
    end

    private
    def uri_for(endpoint, node = :master, node_index = 0)
      if node == :read_replica
        "#{@configuration.read_replica_nodes[node_index][:protocol]}://#{@configuration.read_replica_nodes[node_index][:host]}:#{@configuration.read_replica_nodes[node_index][:port]}#{endpoint}"
      else
        "#{@configuration.master_node[:protocol]}://#{@configuration.master_node[:host]}:#{@configuration.master_node[:port]}#{endpoint}"
      end
    end

    def perform_http_call_with_error_handling(use_read_replicas = :do_not_use_read_replicas)
      @configuration.validate!

      node       = :master
      node_index = -1

      begin
        response_object = yield node, node_index

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
      rescue Net::ReadTimeout, Net::OpenTimeout, Error::ServerError, HTTParty::ResponseError,
          Timeout::Error, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
          Errno::EINVAL, Errno::ENETDOWN, Errno::ENETUNREACH, Errno::ENETRESET, Errno::ECONNABORTED, Errno::ECONNRESET,
          Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::EHOSTDOWN, Errno::EHOSTUNREACH => e
        if (use_read_replicas == :use_read_replicas || use_read_replicas == true) &&
            !@configuration.read_replica_nodes.nil?
          node       = :read_replica
          node_index += 1

          retry if !@configuration.read_replica_nodes[node_index].nil?
        end

        raise
      end
    end

    def default_options
      {
          timeout: @configuration.timeout_seconds
      }
    end

    def default_headers
      {
          "#{API_KEY_HEADER_NAME}" => @configuration.master_node[:api_key]
      }
    end
  end
end