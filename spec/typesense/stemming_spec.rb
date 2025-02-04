# frozen_string_literal: true

require_relative '../spec_helper'

describe 'StemmingDictionaries' do
  let(:client) do
    Typesense::Client.new(
      nodes: [{ host: 'localhost', port: '8108', protocol: 'http' }],
      api_key: 'xyz',
      connection_timeout_seconds: 10
    )
  end

  let(:dictionary_id) { 'test_dictionary' }
  let(:dictionary) do
    [
      { 'root' => 'exampleRoot1', 'word' => 'exampleWord1' },
      { 'root' => 'exampleRoot2', 'word' => 'exampleWord2' }
    ]
  end

  before { WebMock.disable! }
  after { WebMock.enable! }

  it 'can upsert a dictionary' do
    response = client.stemming.dictionaries.upsert(dictionary_id, dictionary)
    expect(response).to eq(dictionary)
  end

  it 'can retrieve a dictionary' do
    response = client.stemming.dictionaries[dictionary_id].retrieve
    expect(response['id']).to eq(dictionary_id)
    expect(response['words']).to eq(dictionary)
  end

  it 'can retrieve all dictionaries' do
    response = client.stemming.dictionaries.retrieve
    expect(response['dictionaries'].length).to eq(1)
    expect(response['dictionaries'][0]).to eq(dictionary_id)
  end
end
