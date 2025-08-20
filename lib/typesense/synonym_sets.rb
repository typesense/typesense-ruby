# frozen_string_literal: true

module Typesense
  class SynonymSets
    RESOURCE_PATH = '/synonym_sets'

    def initialize(api_call)
      @api_call = api_call
      @synonym_sets = {}
    end

    def upsert(synonym_set_name, params)
      @api_call.put(endpoint_path(synonym_set_name), params)
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def [](synonym_set_name)
      @synonym_sets[synonym_set_name] ||= SynonymSet.new(synonym_set_name, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{RESOURCE_PATH}#{"/#{URI.encode_www_form_component(operation)}" unless operation.nil?}"
    end
  end
end
