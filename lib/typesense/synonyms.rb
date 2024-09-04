# frozen_string_literal: true

module Typesense
  class Synonyms
    RESOURCE_PATH = '/synonyms'

    def initialize(collection_name, api_call)
      @collection_name = collection_name
      @api_call        = api_call
      @synonyms = {}
    end

    def upsert(synonym_id, params)
      @api_call.put(endpoint_path(synonym_id), params)
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def [](synonym_id)
      @synonyms[synonym_id] ||= Synonym.new(@collection_name, synonym_id, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{Collections::RESOURCE_PATH}/#{ERB::Util.url_encode(@collection_name)}#{Synonyms::RESOURCE_PATH}#{operation.nil? ? '' : "/#{ERB::Util.url_encode(operation)}"}"
    end
  end
end
