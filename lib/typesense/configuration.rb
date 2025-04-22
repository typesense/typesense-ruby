# frozen_string_literal: true

require 'logger'

module Typesense
  class Configuration
    attr_accessor :nodes, :nearest_node, :connection_timeout_seconds, :healthcheck_interval_seconds, :num_retries, :retry_interval_seconds, :api_key, :logger, :log_level

    def initialize(options = {})
      @nodes = options[:nodes] || []
      @nearest_node = options[:nearest_node]
      @connection_timeout_seconds = options[:connection_timeout_seconds] || options[:timeout_seconds] || 10
      @healthcheck_interval_seconds = options[:healthcheck_interval_seconds] || 15
      @num_retries = options[:num_retries] || (@nodes.length + (@nearest_node.nil? ? 0 : 1)) || 3
      @retry_interval_seconds = options[:retry_interval_seconds] || 0.1
      @api_key = options[:api_key]

      @logger = options[:logger] || Logger.new($stdout)
      @log_level = options[:log_level] || Logger::WARN
      @logger.level = @log_level

      show_deprecation_warnings(options)
      validate!
    end

    def validate!
      if @nodes.nil? ||
         @nodes.empty? ||
         @nodes.any? { |node| node_missing_parameters?(node) }
        raise Error::MissingConfiguration, 'Missing required configuration. Ensure that nodes[][:protocol], nodes[][:host] and nodes[][:port] are set.'
      end

      raise Error::MissingConfiguration, 'Missing required configuration. Ensure that api_key is set.' if @api_key.nil?
    end

    private

    def node_missing_parameters?(node)
      %i[protocol host port].any? { |attr| node.send(:[], attr).nil? }
    end

    def show_deprecation_warnings(options)
      @logger.warn 'Deprecation warning: timeout_seconds is now renamed to connection_timeout_seconds' unless options[:timeout_seconds].nil?
      @logger.warn 'Deprecation warning: master_node is now consolidated to nodes, starting with Typesense Server v0.12' unless options[:master_node].nil?
      @logger.warn 'Deprecation warning: read_replica_nodes is now consolidated to nodes, starting with Typesense Server v0.12' unless options[:read_replica_nodes].nil?
    end
  end
end
