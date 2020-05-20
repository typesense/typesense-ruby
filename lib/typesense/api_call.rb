# frozen_string_literal: true

require 'httparty'

module Typesense
  class ApiCall
    include HTTParty

    API_KEY_HEADER_NAME = 'X-TYPESENSE-API-KEY'

    def initialize(configuration)
      @configuration = configuration

      @api_key = @configuration.api_key
      @nodes = @configuration.nodes.dup # Make a copy, since we'll be adding additional metadata to the nodes
      @distributed_search_node = @configuration.distributed_search_node.dup
      @connection_timeout_seconds = @configuration.connection_timeout_seconds
      @healthcheck_interval_seconds = @configuration.healthcheck_interval_seconds
      @num_retries_per_request = @configuration.num_retries
      @retry_interval_seconds = @configuration.retry_interval_seconds

      @logger = @configuration.logger

      initialize_metadata_for_nodes
      @current_node_index = -1
    end

    def post(endpoint, parameters = {})
      headers, body = extract_headers_and_body_from(parameters)

      perform_request :post,
                      endpoint,
                      body: body,
                      headers: default_headers.merge(headers)
    end

    def put(endpoint, parameters = {})
      headers, body = extract_headers_and_body_from(parameters)

      perform_request :put,
                      endpoint,
                      body: body,
                      headers: default_headers.merge(headers)
    end

    def get(endpoint, parameters = {})
      headers, query = extract_headers_and_query_from(parameters)

      perform_request :get,
                      endpoint,
                      query: query,
                      headers: default_headers.merge(headers)
    end

    def delete(endpoint, parameters = {})
      headers, query = extract_headers_and_query_from(parameters)

      perform_request :delete,
                      endpoint,
                      query: query,
                      headers: default_headers.merge(headers)
    end

    def perform_request(method, endpoint, options = {})
      @configuration.validate!
      last_exception = nil
      @logger.debug "Performing #{method.to_s.upcase} request: #{endpoint}"
      (1..(@num_retries_per_request + 1)).each do |num_tries|
        node = next_node

        @logger.debug "Attempting #{method.to_s.upcase} request Try ##{num_tries} to Node #{node[:index]}"

        begin
          response_object = self.class.send(method,
                                            uri_for(endpoint, node),
                                            default_options.merge(options))
          set_node_healthcheck(node, is_healthy: true) if (1..499).include? response_object.response.code.to_i

          @logger.debug "Request to Node #{node[:index]} was successfully made (at the network layer). Response Code was #{response_object.response.code}."

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
          set_node_healthcheck(node, is_healthy: false)
          last_exception = e
          @logger.warn "Request to Node #{node[:index]} failed due to \"#{e.class}: #{e.message}\""
          @logger.warn "Sleeping for #{@retry_interval_seconds}s and then retrying request..."
          sleep @retry_interval_seconds
        end
      end
      @logger.debug "No retries left. Raising last error \"#{last_exception.class}: #{last_exception.message}\"..."
      raise last_exception
    end

    private

    def extract_headers_and_body_from(parameters)
      if json_request?(parameters)
        headers = { 'Content-Type' => 'application/json' }
        body = sanitize_parameters(parameters).to_json
      else
        headers = {}
        body = parameters[:body]
      end
      [headers, body]
    end

    def extract_headers_and_query_from(parameters)
      if json_request?(parameters)
        headers = { 'Content-Type' => 'application/json' }
        query = sanitize_parameters(parameters)
      else
        headers = {}
        query = parameters[:query]
      end
      [headers, query]
    end

    def json_request?(parameters)
      parameters[:as_json].nil? ? true : parameters[:as_json]
    end

    def sanitize_parameters(parameters)
      sanitized_parameters = parameters.dup
      sanitized_parameters.delete(:as_json)
      sanitized_parameters.delete(:body)
      sanitized_parameters.delete(:query)

      sanitized_parameters
    end

    def uri_for(endpoint, node)
      "#{node[:protocol]}://#{node[:host]}:#{node[:port]}#{endpoint}"
    end

    ## Attempts to find the next healthy node, looping through the list of nodes once.
    #   But if no healthy nodes are found, it will just return the next node, even if it's unhealthy
    #     so we can try the request for good measure, in case that node has become healthy since
    def next_node
      # Check if distributed_search_node is set and is healthy, if so return it
      unless @distributed_search_node.nil?
        candidate_node = @distributed_search_node
        reset_node_healthcheck_if_expired(candidate_node)
        @logger.debug "Nodes health: Node #{candidate_node[:index]} is #{candidate_node[:is_healthy] == true ? 'Healthy' : 'Unhealthy'}"
        if candidate_node[:is_healthy] == true
          @logger.debug "Updated current node to Node #{candidate_node[:index]}"
          return candidate_node
        else
          @logger.debug 'Falling back to individual nodes'
        end
      end

      # Fallback to node as usual
      @logger.debug "Nodes health: #{@nodes.each_with_index.map { |node, i| "Node #{i} is #{node[:is_healthy] == true ? 'Healthy' : 'Unhealthy'}" }.join(' || ')}"
      candidate_node_index = @current_node_index
      candidate_node = @nodes[candidate_node_index]
      (0..@nodes.length).each do |i|
        candidate_node_index = (candidate_node_index + 1) % @nodes.length
        candidate_node = @nodes[candidate_node_index]
        reset_node_healthcheck_if_expired(candidate_node)
        break if candidate_node[:is_healthy] == true

        @logger.debug "No healthy nodes were found. Returning the next node, Node #{candidate_node[:index]}" if i == @nodes.length
      end

      @current_node_index = candidate_node_index
      @logger.debug "Updated current node to Node #{candidate_node[:index]}"

      candidate_node
    end

    def reset_node_healthcheck_if_expired(node)
      return unless node[:is_healthy] == false && (Time.now.to_i - node[:last_healthcheck_timestamp] > @healthcheck_interval_seconds)

      @logger.debug "Node #{node[:index]} has exceeded healthcheck_interval_seconds of #{@healthcheck_interval_seconds}. Adding it back into rotation."
      set_node_healthcheck(node, is_healthy: true)
      @logger.debug "Nodes health: #{@nodes.each_with_index.map { |n, i| "Node #{i} is #{n[:is_healthy] == true ? 'Healthy' : 'Unhealthy'}" }.join(' || ')}"
    end

    def initialize_metadata_for_nodes
      unless @distributed_search_node.nil?
        @distributed_search_node[:index] = 'DistributedSearch'
        set_node_healthcheck(@distributed_search_node, is_healthy: true)
      end
      @nodes.each_with_index do |node, index|
        node[:index] = index
        set_node_healthcheck(node, is_healthy: true)
      end
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
      elsif response.code.to_i.zero?
        Typesense::Error::HTTPStatus0Error
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
