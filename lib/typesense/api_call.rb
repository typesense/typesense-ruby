# frozen_string_literal: true

require 'faraday'
require 'json'

module Typesense
  class ApiCall
    API_KEY_HEADER_NAME = 'X-TYPESENSE-API-KEY'

    attr_reader :logger

    def initialize(configuration)
      @configuration = configuration

      @api_key = @configuration.api_key
      @nodes = @configuration.nodes.dup # Make a copy, since we'll be adding additional metadata to the nodes
      @nearest_node = @configuration.nearest_node.dup
      @connection_timeout_seconds = @configuration.connection_timeout_seconds
      @healthcheck_interval_seconds = @configuration.healthcheck_interval_seconds
      @num_retries_per_request = @configuration.num_retries
      @retry_interval_seconds = @configuration.retry_interval_seconds

      @logger = @configuration.logger

      initialize_metadata_for_nodes
      @current_node_index = -1
    end

    def post(endpoint, body_parameters = {}, query_parameters = {})
      perform_request :post,
                      endpoint,
                      query_parameters: query_parameters,
                      body_parameters: body_parameters
    end

    def patch(endpoint, body_parameters = {}, query_parameters = {})
      perform_request :patch,
                      endpoint,
                      query_parameters: query_parameters,
                      body_parameters: body_parameters
    end

    def put(endpoint, body_parameters = {}, query_parameters = {})
      perform_request :put,
                      endpoint,
                      query_parameters: query_parameters,
                      body_parameters: body_parameters
    end

    def get(endpoint, query_parameters = {})
      perform_request :get,
                      endpoint,
                      query_parameters: query_parameters
    end

    def delete(endpoint, query_parameters = {})
      perform_request :delete,
                      endpoint,
                      query_parameters: query_parameters
    end

    def perform_request(method, endpoint, query_parameters: nil, body_parameters: nil, additional_headers: {})
      @configuration.validate!
      last_exception = nil
      @logger.debug "Performing #{method.to_s.upcase} request: #{endpoint}"
      (1..(@num_retries_per_request + 1)).each do |num_tries|
        node = next_node

        @logger.debug "Attempting #{method.to_s.upcase} request Try ##{num_tries} to Node #{node[:index]}"

        begin
          conn = Faraday.new(uri_for(endpoint, node)) do |f|
            f.options.timeout = @connection_timeout_seconds
            f.options.open_timeout = @connection_timeout_seconds
          end

          headers = default_headers.merge(additional_headers)

          response = conn.send(method) do |req|
            req.headers = headers
            req.params = query_parameters unless query_parameters.nil?
            unless body_parameters.nil?
              body = body_parameters
              body = JSON.dump(body_parameters) if headers['Content-Type'] == 'application/json'
              req.body = body
            end
          end
          set_node_healthcheck(node, is_healthy: true) if response.status.between?(1, 499)

          @logger.debug "Request #{method}:#{uri_for(endpoint, node)} to Node #{node[:index]} was successfully made (at the network layer). response.status was #{response.status}."

          parsed_response = if response.headers && (response.headers['content-type'] || '').include?('application/json')
                              JSON.parse(response.body)
                            else
                              response.body
                            end

          # If response is 2xx return the object, else raise the response as an exception
          return parsed_response if response.status.between?(200, 299)

          exception_message = (parsed_response && parsed_response['message']) || 'Error'
          raise custom_exception_klass_for(response), exception_message
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError,
               Errno::EINVAL, Errno::ENETDOWN, Errno::ENETUNREACH, Errno::ENETRESET,
               Errno::ECONNABORTED, Errno::ECONNRESET, Errno::ETIMEDOUT,
               Errno::ECONNREFUSED, Errno::EHOSTDOWN, Errno::EHOSTUNREACH,
               Typesense::Error::ServerError, Typesense::Error::HTTPStatus0Error => e
          # Rescue network layer exceptions and HTTP 5xx errors, so the loop can continue.
          # Using loops for retries instead of rescue...retry to maintain consistency with client libraries in
          #   other languages that might not support the same construct.
          set_node_healthcheck(node, is_healthy: false)
          last_exception = e
          @logger.warn "Request #{method}:#{uri_for(endpoint, node)} to Node #{node[:index]} failed due to \"#{e.class}: #{e.message}\""
          @logger.warn "Sleeping for #{@retry_interval_seconds}s and then retrying request..."
          sleep @retry_interval_seconds
        end
      end
      @logger.debug "No retries left. Raising last error \"#{last_exception.class}: #{last_exception.message}\"..."
      raise last_exception
    end

    private

    def uri_for(endpoint, node)
      "#{node[:protocol]}://#{node[:host]}:#{node[:port]}#{endpoint}"
    end

    ## Attempts to find the next healthy node, looping through the list of nodes once.
    #   But if no healthy nodes are found, it will just return the next node, even if it's unhealthy
    #     so we can try the request for good measure, in case that node has become healthy since
    def next_node
      # Check if nearest_node is set and is healthy, if so return it
      unless @nearest_node.nil?
        @logger.debug "Nodes health: Node #{@nearest_node[:index]} is #{@nearest_node[:is_healthy] == true ? 'Healthy' : 'Unhealthy'}"
        if @nearest_node[:is_healthy] == true || node_due_for_healthcheck?(@nearest_node)
          @logger.debug "Updated current node to Node #{@nearest_node[:index]}"
          return @nearest_node
        end
        @logger.debug 'Falling back to individual nodes'
      end

      # Fallback to nodes as usual
      @logger.debug "Nodes health: #{@nodes.each_with_index.map { |node, i| "Node #{i} is #{node[:is_healthy] == true ? 'Healthy' : 'Unhealthy'}" }.join(' || ')}"
      candidate_node = nil
      (0..@nodes.length).each do |_i|
        @current_node_index = (@current_node_index + 1) % @nodes.length
        candidate_node = @nodes[@current_node_index]
        if candidate_node[:is_healthy] == true || node_due_for_healthcheck?(candidate_node)
          @logger.debug "Updated current node to Node #{candidate_node[:index]}"
          return candidate_node
        end
      end

      # None of the nodes are marked healthy, but some of them could have become healthy since last health check.
      # So we will just return the next node.
      @logger.debug "No healthy nodes were found. Returning the next node, Node #{candidate_node[:index]}"
      candidate_node
    end

    def node_due_for_healthcheck?(node)
      is_due_for_check = Time.now.to_i - node[:last_access_timestamp] > @healthcheck_interval_seconds
      @logger.debug "Node #{node[:index]} has exceeded healthcheck_interval_seconds of #{@healthcheck_interval_seconds}. Adding it back into rotation." if is_due_for_check
      is_due_for_check
    end

    def initialize_metadata_for_nodes
      unless @nearest_node.nil?
        @nearest_node[:index] = 'nearest_node'
        set_node_healthcheck(@nearest_node, is_healthy: true)
      end
      @nodes.each_with_index do |node, index|
        node[:index] = index
        set_node_healthcheck(node, is_healthy: true)
      end
    end

    def set_node_healthcheck(node, is_healthy:)
      node[:is_healthy] = is_healthy
      node[:last_access_timestamp] = Time.now.to_i
    end

    def custom_exception_klass_for(response)
      if response.status == 400
        Typesense::Error::RequestMalformed.new(response: response)
      elsif response.status == 401
        Typesense::Error::RequestUnauthorized.new(response: response)
      elsif response.status == 404
        Typesense::Error::ObjectNotFound.new(response: response)
      elsif response.status == 409
        Typesense::Error::ObjectAlreadyExists.new(response: response)
      elsif response.status == 422
        Typesense::Error::ObjectUnprocessable.new(response: response)
      elsif response.status.between?(500, 599)
        Typesense::Error::ServerError.new(response: response)
      elsif response.respond_to?(:timed_out?) && response.timed_out?
        Typesense::Error::TimeoutError.new(response: response)
      elsif response.status.zero?
        Typesense::Error::HTTPStatus0Error.new(response: response)
      else
        # This will handle both 300-level responses and any other unhandled status codes
        Typesense::Error::HTTPError.new(response: response)
      end
    end

    def default_headers
      {
        'Content-Type' => 'application/json',
        API_KEY_HEADER_NAME.to_s => @api_key,
        'User-Agent' => 'Typesense Ruby Client'
      }
    end
  end
end
