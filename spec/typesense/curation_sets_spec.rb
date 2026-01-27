# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::CurationSets do
  subject(:curation_sets) { typesense.curation_sets }

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
  end

  after do
    next unless typesense_v30_or_above?

    existing_sets = curation_sets.retrieve
    existing_sets.each do |set|
      curation_sets[set['name']].delete
    end
  rescue StandardError
    # Ignore errors if no curation sets exist
  end

  describe '#upsert' do
    it 'creates a curation set and returns it' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = curation_sets.upsert('test-curation-set', curation_set_data)

      expect(result['items']).to eq(curation_set_data['items'])
    end
  end

  describe '#retrieve' do
    it 'retrieves all curation sets' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      # Create a curation set first
      curation_sets.upsert('test-curation-set', curation_set_data)

      result = curation_sets.retrieve

      expect(result).to be_an(Array)
      expect(result.length).to be >= 1

      # Find our test curation set
      test_set = result.find { |set| set['name'] == 'test-curation-set' }
      expect(test_set).not_to be_nil
      expect(test_set['items']).to eq(curation_set_data['items'])
    end
  end

  describe '#[]' do
    it 'creates a curation set object and returns it' do
      skip('CurationSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = curation_sets['test-curation-set']

      expect(result).to be_a(Typesense::CurationSet)
      expect(result.instance_variable_get(:@curation_set_name)).to eq('test-curation-set')
    end
  end
end
