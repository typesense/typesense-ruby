# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::SynonymSets do
  subject(:synonym_sets) { typesense.synonym_sets }

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

  let(:synonym_set_data) do
    {
      'items' => [
        {
          'id' => 'dummy',
          'synonyms' => %w[foo bar baz],
          'root' => ''
        }
      ]
    }
  end

  before do
    skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?
  end

  after do
    next unless typesense_v30_or_above?

    # Clean up any created synonym sets
    existing_sets = synonym_sets.retrieve
    existing_sets.each do |set|
      synonym_sets[set['name']].delete
    end
  rescue StandardError
    # Ignore errors if no synonym sets exist
  end

  describe '#upsert' do
    it 'creates a synonym set and returns it' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = synonym_sets.upsert('test-synonym-set', synonym_set_data)

      expect(result['items']).to eq(synonym_set_data['items'])
    end
  end

  describe '#retrieve' do
    it 'retrieves all synonym sets' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      # Create a synonym set first
      synonym_sets.upsert('test-synonym-set', synonym_set_data)

      result = synonym_sets.retrieve

      expect(result).to be_an(Array)
      expect(result.length).to be >= 1

      # Find our test synonym set
      test_set = result.find { |set| set['name'] == 'test-synonym-set' }
      expect(test_set).not_to be_nil
      expect(test_set['items']).to eq(synonym_set_data['items'])
    end
  end

  describe '#[]' do
    it 'creates a synonym set object and returns it' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = synonym_sets['test-synonym-set']

      expect(result).to be_a(Typesense::SynonymSet)
      expect(result.instance_variable_get(:@synonym_set_name)).to eq('test-synonym-set')
    end
  end
end
