# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'
require 'timecop'

describe Typesense::ApiCall do
  include_context 'with Typesense configuration'

  subject(:api_call) { described_class.new(typesense.configuration) }

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
        stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 0))
          .to_return(status: response_code,
                     body: JSON.dump('message' => 'Error Message'),
                     headers: { 'Content-Type' => 'application/json' })

        stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 1))
          .to_return(status: response_code,
                     body: JSON.dump('message' => 'Error Message'),
                     headers: { 'Content-Type' => 'application/json' })

        stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 2))
          .to_return(status: response_code,
                     body: JSON.dump('message' => 'Error Message'),
                     headers: { 'Content-Type' => 'application/json' })

        expect { api_call.send(method, '') }.to raise_error error
      end
    end
  end

  shared_examples 'Node selection for write operations' do |method|
    def common_expectations(method, master_node_stub, exception)
      expect { subject.send(method, '') }.to raise_error exception

      expect(master_node_stub).to have_been_requested

      expect(a_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', :read_replica))).not_to have_been_made
    end

    it 'does not use any read replicas and fails immediately when there is a server error' do
      master_node_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', :master))
                         .to_return(status: 500,
                                    body: JSON.dump('message' => 'Error Message'),
                                    headers: { 'Content-Type' => 'application/json' })

      common_expectations(method, master_node_stub, Typesense::Error::ServerError)
    end

    it 'does not use any read replicas and fails immediately when there is a connection timeout' do
      master_node_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', :master)).to_timeout

      common_expectations(method, master_node_stub, Net::OpenTimeout)
    end
  end

  shared_examples 'Node selection' do |method|
    it 'raises an error when no nodes are healthy' do
      node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 0))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 1))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 2))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      expect { subject.send(method, '/') }.to raise_error(Typesense::Error::ServerError)
      expect(node_0_stub).to have_been_requested.times(2) # 4 tries, for 3 nodes by default
      expect(node_1_stub).to have_been_requested
      expect(node_2_stub).to have_been_requested
    end

    it 'selects the next available node when there is a server error' do
      node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 0))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 1))
                    .to_return(status: 500,
                               body: JSON.dump('message' => 'Error Message'),
                               headers: { 'Content-Type' => 'application/json' })

      node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 2))
                    .to_return(status: 200,
                               body: JSON.dump('message' => 'Success'),
                               headers: { 'Content-Type' => 'application/json' })

      expect { subject.send(method, '/') }.not_to raise_error
      expect(node_0_stub).to have_been_requested
      expect(node_1_stub).to have_been_requested
      expect(node_2_stub).to have_been_requested
    end

    it 'selects the next available node when there is a connection timeout' do
      node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 0)).to_timeout
      node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 1)).to_timeout
      node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 2))
                    .to_return(status: 200,
                               body: JSON.dump('message' => 'Success'),
                               headers: { 'Content-Type' => 'application/json' })

      expect { subject.send(method, '/') }.not_to raise_error
      expect(node_0_stub).to have_been_requested
      expect(node_1_stub).to have_been_requested
      expect(node_2_stub).to have_been_requested
    end

    it 'remove unhealthy nodes out of rotation, until threshold' do
      node_0_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 0)).to_timeout
      node_1_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 1)).to_timeout
      node_2_stub = stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 2))
                    .to_return(status: 200,
                               body: JSON.dump('message' => 'Success'),
                               headers: { 'Content-Type' => 'application/json' })
      Timecop.freeze(Time.now) do
        subject.send(method, '/') # Two nodes are unhealthy after this
        subject.send(method, '/') # Request should have been made to node 2
        subject.send(method, '/') # Request should have been made to node 2
      end
      Timecop.freeze(Time.now + 5) do
        subject.send(method, '/') # Request should have been made to node 2
      end
      stub_request(:any, described_class.new(typesense.configuration).send(:uri_for, '/', 0))
      Timecop.freeze(Time.now + 65) do
        subject.send(method, '/') # Request should have been made to node 0, since the unhealthy threshold was exceeded
      end
      expect(node_0_stub).to have_been_requested.times(2)
      expect(node_1_stub).to have_been_requested
      expect(node_2_stub).to have_been_requested.times(4)
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
