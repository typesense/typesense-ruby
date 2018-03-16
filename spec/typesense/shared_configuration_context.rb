require_relative '../spec_helper'

shared_context 'Typesense configuration', shared_context: :metadata do
  let(:typesense) do
    Typesense::Client.new(
        master_node:        {
            host:     'localhost',
            port:     8108,
            protocol: 'http',
            api_key:  'abcd'
        },
        read_replica_nodes: [
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
                            ],
        timeout_seconds:    10
    )
  end
end