# frozen_string_literal: true

module Typesense
  class CurationSets
    RESOURCE_PATH = '/curation_sets'

    def initialize(api_call)
      @api_call = api_call
    end

    def upsert(curation_set_name, curation_set_data)
      @api_call.put("#{self.class::RESOURCE_PATH}/#{URI.encode_www_form_component(curation_set_name)}", curation_set_data)
    end

    def retrieve
      @api_call.get(self.class::RESOURCE_PATH)
    end

    def [](curation_set_name)
      CurationSet.new(curation_set_name, @api_call)
    end
  end
end
