# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::SynonymSetItems do
  subject(:synonym_set_items) { typesense.synonym_sets['test synonym set'].items }

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

    typesense.synonym_sets.upsert('test synonym set', synonym_set_data)
  end

  after do
    typesense.synonym_sets['test synonym set'].delete
  rescue StandardError
    # Ignore errors if already deleted
  end

  describe '#retrieve' do
    it 'retrieves all items in a synonym set' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = synonym_set_items.retrieve

      expect(result).to eq(synonym_set_data['items'])
    end
  end

  describe '#[]' do
    it 'creates a synonym set item object and returns it' do
      skip('SynonymSets is only supported in Typesense v30+') unless typesense_v30_or_above?

      result = synonym_set_items['smart-phone-synonyms']

      expect(result).to be_a(Typesense::SynonymSetItem)
      expect(result.instance_variable_get(:@synonym_set_name)).to eq('test synonym set')
      expect(result.instance_variable_get(:@item_id)).to eq('smart-phone-synonyms')
    end
  end
end
