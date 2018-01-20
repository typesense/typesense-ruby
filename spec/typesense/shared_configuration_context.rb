require_relative '../spec_helper'

shared_context 'Typesense configuration', shared_context: :metadata do
  before(:each) do
    Typesense.configure do |config|
      config.host    = 'localhost'
      config.port    = 8108
      config.api_key = 'abcd'
    end
  end
end