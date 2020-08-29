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
    include_examples 'General error handling', :post
    include_examples 'Node selection', :post
  end

  describe '#get' do
    include_examples 'General error handling', :get
    include_examples 'Node selection', :get
  end

  describe '#delete' do
    include_examples 'General error handling', :delete
    include_examples 'Node selection', :delete
  end
end
