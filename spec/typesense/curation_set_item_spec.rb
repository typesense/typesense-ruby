# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::CurationSetItem do
  subject(:curation_set_item) { typesense.curation_sets['test-curation-set'].items['rule-1'] }

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

    # Create a test curation set
    typesense.curation_sets.upsert('test-curation-set', curation_set_data)
  end

  after do
    typesense.curation_sets['test-curation-set'].delete
  rescue StandardError
    # Ignore errors if already deleted
  end

  describe '#retrieve' do
    it 'returns the specified curation set item' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = curation_set_item.retrieve

      expect(result['id']).to eq('rule-1')
      expect(result['rule']['query']).to eq('test')
    end
  end

  describe '#upsert' do
    it 'updates the specified curation set item' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      updated_item_data = {
        'id' => 'rule-1',
        'rule' => {
          'query' => 'updated test',
          'match' => 'exact'
        },
        'includes' => [{ 'id' => '999', 'position' => 1 }]
      }

      result = curation_set_item.upsert(updated_item_data)

      expect(result['id']).to eq('rule-1')
      expect(result['rule']['query']).to eq('updated test')
      expect(result['includes'].first['id']).to eq('999')
    end
  end

  describe '#delete' do
    it 'deletes the specified curation set item' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = curation_set_item.delete

      expect(result['id']).to eq('rule-1')

      expect { curation_set_item.retrieve }.to raise_error(Typesense::Error::ObjectNotFound)
    end
  end
end
