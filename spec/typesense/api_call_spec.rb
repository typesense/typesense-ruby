# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'
require 'timecop'

describe Typesense::ApiCall do
  subject(:api_call) { described_class.new(typesense.configuration) }

  include_context 'with Typesense configuration'

  shared_examples 'General error handling' do |method|
    {
      400 => Typesense::Error::RequestMalformed,
      401 => Typesense::Error::RequestUnauthorized,
      404 => Typesense::Error::ObjectNotFound,
      409 => Typesense::Error::ObjectAlreadyExists,
      422 => Typesense::Error::ObjectUnprocessable,
      500 => Typesense::Error::ServerError,
      300 => Typesense::Error
    }.each do |response_code, error|
      it "throws #{error} for a #{response_code} response" do
        stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[0]))
          .to_return(status: response_code,
                     body: JSON.dump('message' => 'Error Message'),
                     headers: { 'Content-Type' => 'application/json' })

        stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[1]))
          .to_return(status: response_code,
                     body: JSON.dump('message' => 'Error Message'),
                     headers: { 'Content-Type' => 'application/json' })

        stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[2]))
          .to_return(status: response_code)

        expect { api_call.send(method, '') }.to raise_error error
      end
    end
  end

  shared_examples 'Node selection' do |method|
    it 'does not retry requests when nodes are healthy' do
      node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[0]))
                    .to_return(status: 422,
                               body: JSON.dump('message' => 'Object unprocessable'),
                               headers: { 'Content-Type' => 'application/json' })

      node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[1]))
                    .to_return(status: 409,
                               body: JSON.dump('message' => 'Object already exists'),
                               headers: { 'Content-Type' => 'application/json' })

      node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[2]))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      expect { subject.send(method, '/') }.to raise_error(Typesense::Error::ObjectUnprocessable)
      expect(node_0_stub).to have_been_requested
      expect(node_1_stub).not_to have_been_requested
      expect(node_2_stub).not_to have_been_requested
    end

    it 'raises an error when no nodes are healthy' do
      node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[0]))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[1]))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[2]))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      expect { subject.send(method, '/') }.to raise_error(Typesense::Error::ServerError)
      expect(node_0_stub).to have_been_requested.times(2) # 4 tries, for 3 nodes by default
      expect(node_1_stub).to have_been_requested
      expect(node_2_stub).to have_been_requested
    end

    it 'selects the next available node when there is a server error' do
      node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[0]))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[1]))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[2]))
                    .to_return(status: 200,
                               body: JSON.dump('message' => 'Success'),
                               headers: { 'Content-Type' => 'application/json' })

      expect { subject.send(method, '/') }.not_to raise_error
      expect(node_0_stub).to have_been_requested
      expect(node_1_stub).to have_been_requested
      expect(node_2_stub).to have_been_requested
    end

    it 'selects the next available node when there is a connection timeout' do
      node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[0])).to_timeout
      node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[1])).to_timeout
      node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[2]))
                    .to_return(status: 200,
                               body: JSON.dump('message' => 'Success'),
                               headers: { 'Content-Type' => 'application/json' })

      expect { subject.send(method, '/') }.not_to raise_error
      expect(node_0_stub).to have_been_requested
      expect(node_1_stub).to have_been_requested
      expect(node_2_stub).to have_been_requested
    end

    it 'remove unhealthy nodes out of rotation, until threshold' do
      node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[0])).to_timeout
      node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[1])).to_timeout
      node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[2]))
                    .to_return(status: 200,
                               body: JSON.dump('message' => 'Success'),
                               headers: { 'Content-Type' => 'application/json' })
      current_time = Time.now
      Timecop.freeze(current_time) do
        subject.send(method, '/') # Two nodes are unhealthy after this
        subject.send(method, '/') # Request should have been made to node 2
        subject.send(method, '/') # Request should have been made to node 2
      end
      Timecop.freeze(current_time + 5) do
        subject.send(method, '/') # Request should have been made to node 2
      end
      Timecop.freeze(current_time + 65) do
        subject.send(method, '/') # Request should have been made to node 2, since node 0 and node 1 are still unhealthy, though they were added back into rotation
      end
      stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[0]))
      Timecop.freeze(current_time + 125) do
        subject.send(method, '/') # Request should have been made to node 0, since it is now healthy and the unhealthy threshold was exceeded
      end

      expect(node_0_stub).to have_been_requested.times(3)
      expect(node_1_stub).to have_been_requested.times(2)
      expect(node_2_stub).to have_been_requested.times(5)
    end

    describe 'when nearest_node is specified' do
      let(:typesense) do
        Typesense::Client.new(
          api_key: 'abcd',
          nearest_node: {
            host: 'nearestNode',
            port: 6108,
            protocol: 'http'
          },
          nodes: [
            {
              host: 'node0',
              port: 8108,
              protocol: 'http'
            },
            {
              host: 'node1',
              port: 8108,
              protocol: 'http'
            },
            {
              host: 'node2',
              port: 8108,
              protocol: 'http'
            }
          ],
          connection_timeout_seconds: 10,
          retry_interval_seconds: 0.01
          # log_level: Logger::DEBUG
        )
      end

      it 'uses the nearest_node if it is present and healthy, otherwise fallsback to regular nodes' do
        nearest_node_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nearest_node)).to_timeout
        node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[0])).to_timeout
        node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[1])).to_timeout
        node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[2]))
                      .to_return(status: 200,
                                 body: JSON.dump('message' => 'Success'),
                                 headers: { 'Content-Type' => 'application/json' })
        current_time = Time.now
        Timecop.freeze(current_time) do
          subject.send(method, '/') # Node nearest_node, Node 0 and Node 1 are marked as unhealthy after this, request should have been made to Node 2
          subject.send(method, '/') # Request should have been made to node 2
          subject.send(method, '/') # Request should have been made to node 2
        end
        Timecop.freeze(current_time + 5) do
          subject.send(method, '/') # Request should have been made to node 2
        end
        Timecop.freeze(current_time + 65) do
          subject.send(method, '/') # Request should have been attempted to nearest_node, Node 0 and Node 1, but finally made to Node 2 (since nearest_node, Node 0 and Node 1 are still unhealthy, though they were added back into rotation after the threshold)
        end
        # Let request to nearest_node succeed
        stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nearest_node))
        Timecop.freeze(current_time + 125) do
          subject.send(method, '/') # Request should have been made to node nearest_node, since it is now healthy and the unhealthy threshold was exceeded
          subject.send(method, '/') # Request should have been made to node nearest_node, since no roundrobin if it is present and healthy
          subject.send(method, '/') # Request should have been made to node nearest_node, since no roundrobin if it is present and healthy
        end

        expect(nearest_node_stub).to have_been_requested.times(5)
        expect(node_0_stub).to have_been_requested.times(2)
        expect(node_1_stub).to have_been_requested.times(2)
        expect(node_2_stub).to have_been_requested.times(5)
      end

      it 'raises an error when no nodes are healthy' do
        nearest_node_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nearest_node))
                            .to_return(status: 500,
                                       body: JSON.dump('message' => 'Error Message'),
                                       headers: { 'Content-Type' => 'application/json' })

        node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[0]))
                      .to_return(status: 500,
                                 body: JSON.dump('message' => 'Error Message'),
                                 headers: { 'Content-Type' => 'application/json' })

        node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[1]))
                      .to_return(status: 500,
                                 body: JSON.dump('message' => 'Error Message'),
                                 headers: { 'Content-Type' => 'application/json' })

        node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', typesense.configuration.nodes[2]))
                      .to_return(status: 500,
                                 body: JSON.dump('message' => 'Error Message'),
                                 headers: { 'Content-Type' => 'application/json' })

        expect { subject.send(method, '/') }.to raise_error(Typesense::Error::ServerError)
        expect(nearest_node_stub).to have_been_requested
        expect(node_0_stub).to have_been_requested.times(2)
        expect(node_1_stub).to have_been_requested
        expect(node_2_stub).to have_been_requested
      end
    end
  end

  describe '#post' do
    it_behaves_like 'General error handling', :post
    it_behaves_like 'Node selection', :post
  end

  describe '#get' do
    it_behaves_like 'General error handling', :get
    it_behaves_like 'Node selection', :get
  end

  describe '#delete' do
    it_behaves_like 'General error handling', :delete
    it_behaves_like 'Node selection', :delete
  end

  describe 'concurrent node rotation' do
    it 'preserves round-robin ordering across nodes under concurrent calls' do
      thread_count = 16
      iterations_per_thread = 90
      num_nodes = typesense.configuration.nodes.length

      counts = Array.new(num_nodes, 0)
      counts_mutex = Mutex.new

      threads = Array.new(thread_count) do
        Thread.new do
          local_counts = Array.new(num_nodes, 0)
          iterations_per_thread.times do
            node = api_call.send(:next_node)
            local_counts[node[:index]] += 1
          end
          counts_mutex.synchronize do
            local_counts.each_with_index { |c, i| counts[i] += c }
          end
        end
      end
      threads.each(&:join)

      expected_per_node = (thread_count * iterations_per_thread) / num_nodes
      expect(counts).to all(eq(expected_per_node))
    end

    it 'never returns a node held unhealthy while next_node is called concurrently' do
      unhealthy_node = api_call.instance_variable_get(:@nodes)[1]
      api_call.send(:set_node_healthcheck, unhealthy_node, is_healthy: false)

      threads = Array.new(8) do
        Thread.new do
          Array.new(200) { api_call.send(:next_node)[:index] }
        end
      end

      results = threads.flat_map(&:value)
      expect(results).not_to include(1)
      expect(results).to include(0).and include(2)
    end

    it 'still returns a node when every node is unhealthy under concurrent calls' do
      nodes = api_call.instance_variable_get(:@nodes)
      nodes.each { |node| api_call.send(:set_node_healthcheck, node, is_healthy: false) }

      threads = Array.new(8) do
        Thread.new do
          Array.new(50) { api_call.send(:next_node) }
        end
      end

      results = threads.flat_map(&:value)
      expect(results.length).to eq(8 * 50)
      expect(results).to all(be_a(Hash))
      expect(results.map { |n| n[:index] }).to all(be_between(0, nodes.length - 1).inclusive)
    end

    it 'maintains invariants when health is toggled on multiple nodes concurrently with reads' do
      nodes = api_call.instance_variable_get(:@nodes)

      writer_threads = nodes.map.with_index do |node, idx|
        Thread.new do
          200.times { |i| api_call.send(:set_node_healthcheck, node, is_healthy: (i + idx).even?) }
        end
      end

      reader_threads = Array.new(8) do
        Thread.new do
          Array.new(200) { api_call.send(:next_node) }
        end
      end

      writer_threads.each(&:join)
      reader_results = reader_threads.flat_map(&:value)

      expect(reader_results.length).to eq(8 * 200)
      expect(reader_results).to all(be_a(Hash))
      expect(reader_results.map { |n| n[:index] }).to all(be_between(0, nodes.length - 1).inclusive)
      nodes.each do |node|
        expect(node[:is_healthy]).to be(true).or be(false)
        expect(node[:last_access_timestamp]).to be_a(Integer)
      end
    end

    it 'picks a recovering node back up under concurrent reads after it is marked healthy again' do
      nodes = api_call.instance_variable_get(:@nodes)
      api_call.send(:set_node_healthcheck, nodes[1], is_healthy: false)

      stop = false
      reader_threads = Array.new(4) do
        Thread.new do
          collected = []
          collected << api_call.send(:next_node)[:index] until stop
          collected
        end
      end

      # Let readers spin while node 1 is unhealthy, then mark it healthy again.
      sleep 0.05
      api_call.send(:set_node_healthcheck, nodes[1], is_healthy: true)
      sleep 0.05
      stop = true

      results = reader_threads.flat_map(&:value)
      expect(results).to include(1)
      expect(results).to all(be_between(0, nodes.length - 1).inclusive)
    end

    context 'with a single node' do
      let(:typesense) do
        Typesense::Client.new(
          api_key: 'abcd',
          nodes: [{ host: 'node0', port: 8108, protocol: 'http' }],
          connection_timeout_seconds: 10,
          retry_interval_seconds: 0.01,
          log_level: Logger::ERROR
        )
      end

      it 'returns the single node and keeps health state consistent under concurrent writes' do
        node = typesense.configuration.nodes[0]

        threads = Array.new(8) do |i|
          Thread.new do
            50.times do
              api_call.send(:set_node_healthcheck, node, is_healthy: i.even?)
              api_call.send(:next_node)
            end
          end
        end
        threads.each(&:join)

        expect(node[:is_healthy]).to be(true).or be(false)
        expect(node[:last_access_timestamp]).to be_a(Integer)
      end
    end

    context 'with nearest_node configured' do
      let(:typesense) do
        Typesense::Client.new(
          api_key: 'abcd',
          nearest_node: { host: 'nearestNode', port: 6108, protocol: 'http' },
          nodes: [
            { host: 'node0', port: 8108, protocol: 'http' },
            { host: 'node1', port: 8108, protocol: 'http' },
            { host: 'node2', port: 8108, protocol: 'http' }
          ],
          connection_timeout_seconds: 10,
          retry_interval_seconds: 0.01,
          log_level: Logger::ERROR
        )
      end

      it 'serializes reads and writes of nearest_node health state under concurrent access' do
        nearest_node = api_call.instance_variable_get(:@nearest_node)

        writer_threads = Array.new(4) do |i|
          Thread.new do
            100.times { api_call.send(:set_node_healthcheck, nearest_node, is_healthy: i.even?) }
          end
        end

        reader_threads = Array.new(8) do
          Thread.new do
            Array.new(100) { api_call.send(:next_node) }
          end
        end

        writer_threads.each(&:join)
        reader_results = reader_threads.flat_map(&:value)

        expect(reader_results).to all(be_a(Hash))
        expect(nearest_node[:is_healthy]).to be(true).or be(false)
        expect(nearest_node[:last_access_timestamp]).to be_a(Integer)
      end
    end
  end

  describe 'keep-alive connection caching' do
    subject(:api_call) { described_class.new(keep_alive_typesense.configuration) }

    let(:keep_alive_typesense) do
      Typesense::Client.new(
        api_key: 'abcd',
        nodes: typesense.configuration.nodes,
        connection_timeout_seconds: 10,
        retry_interval_seconds: 0.01,
        log_level: Logger::ERROR,
        keep_alive_connections: true
      )
    end

    let(:node) { keep_alive_typesense.configuration.nodes[0] }

    before do
      keep_alive_typesense.configuration.nodes.each do |n|
        stub_request(:any, api_call.send(:uri_for, '/', n))
          .to_return(status: 200, body: JSON.dump('ok' => true), headers: { 'Content-Type' => 'application/json' })
      end
    end

    it 'reuses the same Faraday connection across calls to the same node on the same thread' do
      first = api_call.send(:connection_for, node)
      second = api_call.send(:connection_for, node)

      expect(second).to be(first)
    end

    it 'caches connections separately per node' do
      first_node_conn = api_call.send(:connection_for, keep_alive_typesense.configuration.nodes[0])
      second_node_conn = api_call.send(:connection_for, keep_alive_typesense.configuration.nodes[1])

      expect(second_node_conn).not_to be(first_node_conn)
    end

    it 'isolates the cache per thread' do
      main_thread_conn = api_call.send(:connection_for, node)

      other_thread_conn = Thread.new { api_call.send(:connection_for, node) }.value

      expect(other_thread_conn).not_to be(main_thread_conn)
    end

    it 'isolates the cache per ApiCall instance' do
      other_api_call = described_class.new(keep_alive_typesense.configuration)

      expect(other_api_call.send(:connection_for, node))
        .not_to be(api_call.send(:connection_for, node))
    end

    it 'evicts the cached connection when a network error occurs so retries open a fresh socket' do
      timeout_node = keep_alive_typesense.configuration.nodes[0]
      keep_alive_typesense.configuration.nodes.each do |n|
        stub_request(:any, api_call.send(:uri_for, '/', n)).to_timeout
      end

      pre_call_conn = api_call.send(:connection_for, timeout_node)

      begin
        api_call.get('/')
      rescue StandardError
        # expected: all nodes time out
      end

      cache = Thread.current[api_call.instance_variable_get(:@thread_connections_key)] || {}
      expect(cache[api_call.send(:connection_key, timeout_node)]).to be_nil

      post_retry_conn = api_call.send(:connection_for, timeout_node)
      expect(post_retry_conn).not_to be(pre_call_conn)
    end

    it 'uses the configured timeouts on the cached connection' do
      conn = api_call.send(:connection_for, node)

      expect(conn.options.timeout).to eq(keep_alive_typesense.configuration.connection_timeout_seconds)
      expect(conn.options.open_timeout).to eq(keep_alive_typesense.configuration.connection_timeout_seconds)
    end

    it 'defaults the idle timeout to 30 seconds' do
      expect(keep_alive_typesense.configuration.keep_alive_idle_timeout_seconds).to eq(30)
    end

    it 'honours a custom keep_alive_idle_timeout_seconds' do
      custom_client = Typesense::Client.new(
        api_key: 'abcd',
        nodes: typesense.configuration.nodes,
        connection_timeout_seconds: 10,
        log_level: Logger::ERROR,
        keep_alive_connections: true,
        keep_alive_idle_timeout_seconds: 5
      )

      expect(custom_client.configuration.keep_alive_idle_timeout_seconds).to eq(5)
      expect(described_class.new(custom_client.configuration).instance_variable_get(:@keep_alive_idle_timeout_seconds)).to eq(5)
    end

    it 'defaults the pool size to 1' do
      expect(keep_alive_typesense.configuration.keep_alive_pool_size).to eq(1)
    end

    it 'honours a custom keep_alive_pool_size' do
      custom_client = Typesense::Client.new(
        api_key: 'abcd',
        nodes: typesense.configuration.nodes,
        connection_timeout_seconds: 10,
        log_level: Logger::ERROR,
        keep_alive_connections: true,
        keep_alive_pool_size: 5
      )

      expect(custom_client.configuration.keep_alive_pool_size).to eq(5)
      expect(described_class.new(custom_client.configuration).instance_variable_get(:@keep_alive_pool_size)).to eq(5)
    end
  end

  describe 'keep-alive disabled (default)' do
    it 'is off by default on the configuration' do
      expect(typesense.configuration.keep_alive_connections).to be(false)
    end

    it 'builds a fresh Faraday connection per request' do
      stub_request(:any, api_call.send(:uri_for, '/', typesense.configuration.nodes[0]))
        .to_return(status: 200, body: JSON.dump('ok' => true), headers: { 'Content-Type' => 'application/json' })

      api_call.get('/')

      expect(Thread.current[api_call.instance_variable_get(:@thread_connections_key)]).to be_nil
    end

    it 'raises when keep_alive_idle_timeout_seconds is set without keep_alive_connections' do
      expect do
        Typesense::Client.new(
          api_key: 'abcd',
          nodes: typesense.configuration.nodes,
          log_level: Logger::ERROR,
          keep_alive_idle_timeout_seconds: 5
        )
      end.to raise_error(Typesense::Error::MissingConfiguration, /keep_alive_connections: true/)
    end

    it 'raises when keep_alive_pool_size is set without keep_alive_connections' do
      expect do
        Typesense::Client.new(
          api_key: 'abcd',
          nodes: typesense.configuration.nodes,
          log_level: Logger::ERROR,
          keep_alive_pool_size: 4
        )
      end.to raise_error(Typesense::Error::MissingConfiguration, /keep_alive_connections: true/)
    end
  end
end
