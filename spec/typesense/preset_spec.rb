# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::Preset do
  subject(:preset) { typesense.presets['search-view'] }

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

  describe '#retrieve' do
    it 'returns the specified preset' do
      stub_request(:get, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/presets/search-view', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key,
                'Content-Type': 'application/json'
              })
        .to_return(status: 200, body: JSON.dump(preset_data), headers: { 'Content-Type': 'application/json' })

      result = preset.retrieve

      expect(result).to eq(preset_data)
    end
  end

  describe '#delete' do
    it 'deletes the specified preset' do
      stub_request(:delete, Typesense::ApiCall.new(typesense.configuration).send(:uri_for, '/presets/search-view', typesense.configuration.nodes[0]))
        .with(headers: {
                'X-Typesense-Api-Key' => typesense.configuration.api_key
              })
        .to_return(status: 200, body: JSON.dump('name' => 'search-view'), headers: { 'Content-Type': 'application/json' })

      result = preset.delete

      expect(result).to eq('name' => 'search-view')
    end
  end
end
