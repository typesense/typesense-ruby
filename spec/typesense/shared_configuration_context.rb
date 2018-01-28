require_relative '../spec_helper'

shared_context 'Typesense configuration', shared_context: :metadata do
  before(:each) do
    Typesense.configure do |config|
      config.master_node = {
          host:     'localhost',
          port:     8108,
          protocol: 'http',
          api_key:  'abcd'
      }
      
      config.read_replica_nodes = [
          {
              host:     'read_replica_1',
              port:     8108,
              protocol: 'http',
              api_key:  'abcd'
          },
          {
              host:     'read_replica_2',
              port:     8108,
              protocol: 'http',
              api_key:  'abcd'
          }
      ]

      config.timeout = 10
    end
  end
end