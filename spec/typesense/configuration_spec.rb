# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Configuration do
  include_context 'with Typesense configuration'

  subject(:configuration) { typesense.configuration }

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
end
