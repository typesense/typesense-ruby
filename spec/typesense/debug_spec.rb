require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Debug do
  include_context 'Typesense configuration'

  subject { Typesense::Debug }

  describe '.retrieve' do
    it 'retrieves debugging information' do
      debug_info = {
          "version" => "0.8.0"
      }
      stub_request(:get, Typesense::ApiCall.send(:uri_for, '/debug')).
          with(headers: {
                   'X-Typesense-Api-Key' => Typesense.configuration.master_node[:api_key]
               }).
          to_return(status: 200, body: JSON.dump(debug_info), headers: { 'Content-Type': 'application/json' })

      result = Typesense::Debug.retrieve

      expect(result).to eq(debug_info)
    end
  end
end

