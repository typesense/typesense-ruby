# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::CurationSetItems do
  subject(:curation_set_items) { typesense.curation_sets['test-curation-set'].items }

  let(:typesense) do
    Typesense::Client.new(
      api_key: 'xyz',
      nodes: [
        {
          host: 'localhost',
          port: 8108,
          protocol: 'http'
        }
      ],
      connection_timeout_seconds: 10,
      retry_interval_seconds: 0.01
    )
  end

  let(:curation_set_data) do
    {
      'items' => [
        {
          'id' => 'rule-1',
          'rule' => {
            'query' => 'test',
            'match' => 'exact'
          },
          'includes' => [{ 'id' => '123', 'position' => 1 }],
          'excludes' => [],
          'filter_curated_hits' => false,
          'remove_matched_tokens' => false,
          'stop_processing' => true
        }
      ]
    }
  end

  before do
    skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

    typesense.curation_sets.upsert('test-curation-set', curation_set_data)
  end

  after do
    typesense.curation_sets['test-curation-set'].delete
  rescue StandardError
    # Ignore errors if already deleted
  end

  describe '#retrieve' do
    it 'retrieves all items in a curation set' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = curation_set_items.retrieve

      expect(result).to be_an(Array)
      expect(result.length).to be >= 1
      expect(result.first['id']).to eq('rule-1')
    end
  end

  describe '#[]' do
    it 'creates a curation set item object and returns it' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = curation_set_items['rule-1']

      expect(result).to be_a(Typesense::CurationSetItem)
      expect(result.instance_variable_get(:@curation_set_name)).to eq('test-curation-set')
      expect(result.instance_variable_get(:@item_id)).to eq('rule-1')
    end
  end
end
