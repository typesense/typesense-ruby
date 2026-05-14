# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Configuration do
  subject(:configuration) { typesense.configuration }

  include_context 'with Typesense configuration'

  describe '#validate!' do
    it 'throws an Error if the nodes config is not set' do
      typesense.configuration.nodes = nil

      expect { configuration.validate! }.to raise_error Typesense::Error::MissingConfiguration
    end

    it 'throws an Error if the api_key config is not set' do
      typesense.configuration.api_key = nil

      expect { configuration.validate! }.to raise_error Typesense::Error::MissingConfiguration
    end

    %i[protocol host port].each do |config_value|
      it "throws an Error if nodes config value for #{config_value} is nil" do
        typesense.configuration.nodes[0].send(:[]=, config_value.to_sym, nil)

        expect { configuration.validate! }.to raise_error Typesense::Error::MissingConfiguration
      end
    end
  end

  describe '#num_retries default' do
    let(:base_options) do
      {
        api_key: 'abcd',
        nodes: [
          { host: 'node0', port: 8108, protocol: 'http' },
          { host: 'node1', port: 8108, protocol: 'http' },
          { host: 'node2', port: 8108, protocol: 'http' }
        ],
        log_level: Logger::ERROR
      }
    end

    it 'defaults to the number of nodes when no nearest_node is set' do
      config = described_class.new(base_options)
      expect(config.num_retries).to eq(3)
    end

    it 'defaults to nodes.length + 1 when a nearest_node is set' do
      config = described_class.new(
        base_options.merge(nearest_node: { host: 'nearestNode', port: 6108, protocol: 'http' })
      )
      expect(config.num_retries).to eq(4)
    end

    it 'falls back to a minimum of 3 for single-node setups' do
      config = described_class.new(
        base_options.merge(nodes: [{ host: 'node0', port: 8108, protocol: 'http' }])
      )
      expect(config.num_retries).to eq(3)
    end

    it 'honors an explicit num_retries option' do
      config = described_class.new(base_options.merge(num_retries: 7))
      expect(config.num_retries).to eq(7)
    end

    it 'honors an explicit num_retries of 0 (Integer is truthy in Ruby)' do
      config = described_class.new(base_options.merge(num_retries: 0))
      expect(config.num_retries).to eq(0)
    end
  end
end
