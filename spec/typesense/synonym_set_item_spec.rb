# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::SynonymSetItem do
  subject(:synonym_set_item) { typesense.synonym_sets['test-synonym-set'].items['smart-phone-synonyms'] }

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
          'id' => 'smart-phone-synonyms',
          'synonyms' => ['smart phone', 'android', 'iphone'],
          'root' => ''
        }
      ]
    }
  end

  before do
    skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

    typesense.synonym_sets.upsert('test-synonym-set', synonym_set_data)
  end

  after do
    typesense.synonym_sets['test-synonym-set'].delete
  rescue StandardError
    # Ignore errors if already deleted
  end

  describe '#retrieve' do
    it 'returns the specified synonym set item' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = synonym_set_item.retrieve

      expect(result).to eq(synonym_set_data['items'].first)
    end
  end

  describe '#upsert' do
    it 'updates the specified synonym set item' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = synonym_set_item.upsert('synonyms' => %w[smartphone mobile], 'root' => 'smartphone')

      expect(result['id']).to eq('smart-phone-synonyms')
      expect(result['synonyms']).to eq(%w[smartphone mobile])
      expect(result['root']).to eq('smartphone')
    end

    it 'creates an item that does not exist yet' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      typesense.synonym_sets['test-synonym-set'].items['tablet synonyms'].upsert('synonyms' => %w[tablet ipad])

      items = typesense.synonym_sets['test-synonym-set'].items.retrieve
      expect(items.map { |item| item['id'] }).to contain_exactly('smart-phone-synonyms', 'tablet synonyms')
    end
  end

  describe '#delete' do
    it 'deletes the specified synonym set item' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = synonym_set_item.delete

      expect(result['id']).to eq('smart-phone-synonyms')

      expect { synonym_set_item.retrieve }.to raise_error(Typesense::Error::ObjectNotFound)
    end
  end
end
