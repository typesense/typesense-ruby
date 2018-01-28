module Typesense
  class Configuration
    attr_accessor :master_node
    attr_accessor :read_replica_nodes
    attr_accessor :timeout

    def initialize
      @master_node = {
          host:     'localhost',
          port:     '8108',
          protocol: 'http'
      }

      @read_replica_nodes = []

      @timeout = 10
    end
  end
end