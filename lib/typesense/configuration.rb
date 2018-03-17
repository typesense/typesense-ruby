# frozen_string_literal: true

module Typesense
  class Configuration
    attr_accessor :master_node
    attr_accessor :read_replica_nodes
    attr_accessor :timeout_seconds

    def initialize(options = {})
      @master_node = options[:master_node] || {
        host:     'localhost',
        port:     '8108',
        protocol: 'http'
      }

      @read_replica_nodes = options[:read_replica_nodes] || []
      @timeout_seconds    = options[:timeout_seconds] || 10
    end

    def validate!
      if @master_node.nil? ||
         node_missing_parameters?(@master_node)
        raise Error::MissingConfiguration, 'Missing required configuration. Ensure that master_node[:protocol], master_node[:host], master_node[:port] and master_node[:api_key] are set.'
      end

      if !@read_replica_nodes.nil? &&
         @read_replica_nodes.any? { |node| node_missing_parameters?(node) }
        raise Error::MissingConfiguration, 'Missing required configuration for read_replica_nodes. Ensure that read_replica_nodes[][:protocol], read_replica_nodes[][:host], read_replica_nodes[][:port] and read_replica_nodes[][:api_key] are set.'
      end
    end

    private

    def node_missing_parameters?(node)
      %i[protocol host port api_key].any? { |attr| node.send(:[], attr).nil? }
    end
  end
end
