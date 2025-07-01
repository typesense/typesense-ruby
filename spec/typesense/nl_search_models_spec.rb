# frozen_string_literal: true

require_relative '../spec_helper'

describe 'NlSearchModels', :integration do
  # These tests require external API access and should not run on CI by default
  next unless ENV['OPENAI_API_KEY']

  let(:client) do
    Typesense::Client.new(
      nodes: [{ host: 'localhost', port: '8108', protocol: 'http' }],
      api_key: 'xyz',
      connection_timeout_seconds: 10
    )
  end


  def create_model_schema(id_suffix = nil)
    model_id = id_suffix ? "test_openai_model_#{id_suffix}" : "test_openai_model_#{Time.now.to_i}_#{rand(1000)}"
    {
      'id' => model_id,
      'model_name' => 'openai/gpt-4.1',
      'api_key' => ENV['OPENAI_API_KEY'],
      'max_bytes' => 16000,
      'temperature' => 0.0
    }
  end

  def cleanup_model(model_id)
    client.nl_search_models[model_id].delete
  rescue Typesense::Error::ObjectNotFound
    # Model doesn't exist, that's fine
  end

  before do
    WebMock.disable!
  end

  after do
    WebMock.enable!
  end

  it 'can create a nl search model' do
    model_schema = create_model_schema('create_test')
    
    begin
      response = client.nl_search_models.create(model_schema)
      expect(response['id']).to eq(model_schema['id'])
      expect(response['model_name']).to eq('openai/gpt-4.1')
      expect(response['max_bytes']).to eq(16000)
      expect(response['temperature']).to eq(0.0)
    ensure
      cleanup_model(model_schema['id'])
    end
  end

  it 'can retrieve a specific nl search model' do
    model_schema = create_model_schema('retrieve_test')
    
    begin
      client.nl_search_models.create(model_schema)
      response = client.nl_search_models[model_schema['id']].retrieve
      expect(response['id']).to eq(model_schema['id'])
      expect(response['model_name']).to eq('openai/gpt-4.1')
    ensure
      cleanup_model(model_schema['id'])
    end
  end

  it 'can retrieve all nl search models' do
    model_schema = create_model_schema('list_test')
    
    begin
      client.nl_search_models.create(model_schema)
      
      response = client.nl_search_models.retrieve
      expect(response).to be_an(Array)
      expect(response.length).to be >= 1
      
      model_ids = response.map { |model| model['id'] }
      expect(model_ids).to include(model_schema['id'])
    ensure
      cleanup_model(model_schema['id'])
    end
  end

  it 'can update a nl search model' do
    model_schema = create_model_schema('update_test')
    
    begin
      client.nl_search_models.create(model_schema)
      
      update_schema = {
        'temperature' => 0.5,
        'system_prompt' => 'Updated system prompt for electronics search'
      }
      
      response = client.nl_search_models[model_schema['id']].update(update_schema)
      expect(response['temperature']).to eq(0.5)
      expect(response['system_prompt']).to eq('Updated system prompt for electronics search')
    ensure
      cleanup_model(model_schema['id'])
    end
  end

  it 'can delete a nl search model' do
    model_schema = create_model_schema('delete_test')
    
    client.nl_search_models.create(model_schema)
    
    response = client.nl_search_models[model_schema['id']].delete
    expect(response['id']).to eq(model_schema['id'])
    
    expect {
      client.nl_search_models[model_schema['id']].retrieve
    }.to raise_error(Typesense::Error::ObjectNotFound)
  end
end 