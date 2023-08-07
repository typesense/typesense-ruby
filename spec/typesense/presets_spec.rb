# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Presets do
  subject(:presets) { typesense.presets }

  include_context 'with Typesense configuration'

  let(:preset_data) do
    {
      'name' => 'search-view',
      'value' => {
        'query_by' => 'title,subjects,author',
        'query_by_weights' => '1,4,8',
        'sort_by' => '_text_match:desc'
      }
    }
  end

  describe '#upsert' do
    it 'creates a preset and returns it' do
      stub_request(:put, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/presets/search-view', typesense.configuration.nodes[0]))
        .with(body: preset_data,
              headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 201, body: JSON.dump(preset_data), headers: { 'Content-Type': 'application/json' })

      result = presets.upsert(preset_data['name'], preset_data)

      expect(result).to eq(preset_data)
    end
  end

  describe '#retrieve' do
    it 'retrieves all presets' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/presets', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type' => 'application/json'
              })
        .to_return(status: 201, body: JSON.dump([preset_data]), headers: { 'Content-Type': 'application/json' })

      result = presets.retrieve

      expect(result).to eq([preset_data])
    end
  end

  describe '#[]' do
    it 'creates a preset object and returns it' do
      result = presets['search-view']

      expect(result).to be_a_kind_of(Typesense::Preset)
      expect(result.instance_variable_get(:@preset_name)).to eq('search-view')
    end
  end
end
