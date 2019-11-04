# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::Configuration do
  include_context 'with Typesense configuration'

  subject(:configuration) { typesense.configuration }

  describe '#validate!' do
    it 'throws an Error if the master_node config is not set' do
      typesense.configuration.master_node = nil

      expect { configuration.validate! }.to raise_error Typesense::Error::MissingConfiguration
    end

    %i[protocol host port api_key].each do |config_value|
      it "throws an Error if master config value for #{config_value} is nil" do
        typesense.configuration.master_node.send(:[]=, config_value.to_sym, nil)

        expect { configuration.validate! }.to raise_error Typesense::Error::MissingConfiguration
      end

      it "throws an Error if read_replica configs for #{config_value} is missing values" do
        typesense.configuration.read_replica_nodes[0].send(:[]=, config_value.to_sym, nil)

        expect { configuration.validate! }.to raise_error Typesense::Error::MissingConfiguration
      end
    end
  end
end
