# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::SynonymSet do
  subject(:synonym_set) { typesense.synonym_sets['test-synonym-set'] }

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
      'synonyms' => [
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

    # Create a test synonym set
    typesense.synonym_sets.upsert('test-synonym-set', synonym_set_data)
  end

  after do
    # Clean up the test synonym set
    typesense.synonym_sets['test-synonym-set'].delete
  rescue StandardError
    # Ignore errors if already deleted
  end

  describe '#retrieve' do
    it 'returns the specified synonym set' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = synonym_set.retrieve

      expect(result['synonyms']).to eq(synonym_set_data['synonyms'])
    end
  end

  describe '#delete' do
    it 'deletes the specified synonym set' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = synonym_set.delete

      expect(result['name']).to eq('test-synonym-set')

      # Verify it's deleted by trying to retrieve it
      expect { synonym_set.retrieve }.to raise_error(Typesense::Error::ObjectNotFound)
    end
  end
end
