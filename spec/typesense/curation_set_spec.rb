# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::CurationSet do
  subject(:curation_set) { typesense.curation_sets['test-curation-set'] }

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
    it 'returns the specified curation set' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = curation_set.retrieve

      expect(result['items']).to eq(curation_set_data['items'])
    end
  end

  describe '#delete' do
    it 'deletes the specified curation set' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = curation_set.delete

      expect(result['name']).to eq('test-curation-set')

      # Verify it's deleted by trying to retrieve it
      expect { curation_set.retrieve }.to raise_error(Typesense::Error::ObjectNotFound)
    end
  end

  describe '#items' do
    it 'returns a CurationSetItems instance' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      items = curation_set.items

      expect(items).to be_a(Typesense::CurationSetItems)
      expect(items.instance_variable_get(:@curation_set_name)).to eq('test-curation-set')
    end
  end
end
