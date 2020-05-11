# frozen_string_literal: true

require 'httparty'

module Typesense
  class ApiCall
    include HTTParty

    API_KEY_HEADER_NAME = 'X-TYPESENSE-API-KEY'

    def initialize(configuration)
      @configuration = configuration

      @api_key = @configuration.api_key
      @nodes = @configuration.nodes
      @connection_timeout_seconds = @configuration.connection_timeout_seconds
      @healthcheck_interval_seconds = @configuration.healthcheck_interval_seconds
      @num_retries_per_request = @configuration.num_retries
      @retry_interval_seconds = @configuration.retry_interval_seconds

      @logger = configuration.logger

      initialize_metadata_for_nodes
      @current_node_index = -1
    end

    def post(endpoint, parameters = {})
      perform_request :post,
                      endpoint,
                      body: parameters.to_json,
                      headers: default_headers.merge('Content-Type' => 'application/json')
    end

    def put(endpoint, parameters = {})
      perform_request :put,
                      endpoint,
                      body: parameters.to_json,
                      headers: default_headers.merge('Content-Type' => 'application/json')
    end

    def get(endpoint, parameters = {})
      perform_request :get,
                      endpoint,
                      query: parameters,
                      headers: default_headers.merge('Content-Type' => 'application/json')
    end

    def delete(endpoint, parameters = {})
      perform_request :delete,
                      endpoint,
                      query: parameters,
                      headers: default_headers
    end

    def perform_request(method, endpoint, options = {})
      @configuration.validate!
      last_exception = nil
      @logger.debug "Performing #{method.to_s.upcase} request: #{endpoint}"
      (1..(@num_retries_per_request + 1)).each do |num_tries|
        update_current_node

        @logger.debug "Attempting #{method.to_s.upcase} request Try ##{num_tries} to Node #{@current_node_index}"

        set_node_healthcheck(current_node, is_healthy: false) # Guilty until proven innocent
        begin
          response_object = self.class.send(method,
                                            uri_for(endpoint),
                                            default_options.merge(options))

          @logger.debug "Request to Node #{@current_node_index} was successfully made (at the network layer). Response Code was #{response_object.response.code}."
          set_node_healthcheck(current_node, is_healthy: true) if (1..499).include? response_object.response.code.to_i

          # If response is 2xx return the object, else raise the response as an exception
          return response_object.parsed_response if response_object.response.code_type <= Net::HTTPSuccess # 2xx

          raise custom_exception_klass_for(response_object.response), response_object.parsed_response['message'] || 'Error message not available'
        rescue Net::ReadTimeout, Net::OpenTimeout,
               EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
               Errno::EINVAL, Errno::ENETDOWN, Errno::ENETUNREACH, Errno::ENETRESET, Errno::ECONNABORTED, Errno::ECONNRESET,
               Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::EHOSTDOWN, Errno::EHOSTUNREACH,
               Timeout::Error, HTTParty::ResponseError, Typesense::Error::ServerError, Typesense::Error::HTTPStatus0Error => e
          # Rescue network layer exceptions and HTTP 5xx errors, so the loop can continue.
          # Using loops for retries instead of rescue...retry to maintain consistency with client libraries in
          #   other languages that might not support the same construct.
          last_exception = e
          @logger.debug "Request to Node #{@current_node_index} failed due to \"#{e.class}: #{e.message}\""
          @logger.debug "Sleeping for #{@retry_interval_seconds}s and then retrying request..."
          sleep @retry_interval_seconds
        end
      end
      @logger.debug "No retries left. Raising last error \"#{last_exception.class}: #{last_exception.message}\"..."
      raise last_exception
    end

    private

    def current_node
      @nodes[@current_node_index]
    end

    def uri_for(endpoint, node_index = @current_node_index)
      "#{@nodes[node_index][:protocol]}://#{@nodes[node_index][:host]}:#{@nodes[node_index][:port]}#{endpoint}"
    end

    ## Attempts to find the next healthy node, looping through the list of nodes once.
    #   But if no healthy nodes are found, it will just return the next node, even if it's unhealthy
    #     so we can try the request for good measure, in case that node has become healthy since
    def update_current_node
      (0..@nodes.length).each do |_i|
        @current_node_index = (@current_node_index + 1) % @nodes.length
        reset_node_healthcheck_if_expired(current_node)
        break if current_node[:is_healthy] == true
      end
      @logger.debug "Updated current node to Node #{@current_node_index}"

      current_node
    end

    def reset_node_healthcheck_if_expired(node)
      return unless node[:is_healthy] == false && (Time.now.to_i - node[:last_healthcheck_timestamp] > @healthcheck_interval_seconds)

      set_node_healthcheck(node, is_healthy: true)
    end

    def initialize_metadata_for_nodes
      @nodes.each { |node| set_node_healthcheck(node, is_healthy: true) }
    end

    def set_node_healthcheck(node, is_healthy:)
      node[:is_healthy] = is_healthy
      node[:last_healthcheck_timestamp] = Time.now.to_i
    end

    def custom_exception_klass_for(response)
      response_code_type = response.code_type
      if response_code_type <= Net::HTTPBadRequest # 400
        Typesense::Error::RequestMalformed
      elsif response_code_type <= Net::HTTPUnauthorized # 401
        Typesense::Error::RequestUnauthorized
      elsif response_code_type <= Net::HTTPNotFound # 404
        Typesense::Error::ObjectNotFound
      elsif response_code_type <= Net::HTTPConflict # 409
        Typesense::Error::ObjectAlreadyExists
      elsif response_code_type <= Net::HTTPUnprocessableEntity # 422
        Typesense::Error::ObjectUnprocessable
      elsif response_code_type <= Net::HTTPServerError # 5xx
        Typesense::Error::ServerError
      else
        Typesense::Error::HTTPError
      end
    end

    def default_options
      {
        timeout: @connection_timeout_seconds
      }
    end

    def default_headers
      {
        API_KEY_HEADER_NAME.to_s => @api_key
      }
    end
  end
end
