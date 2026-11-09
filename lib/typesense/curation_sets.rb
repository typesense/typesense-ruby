# frozen_string_literal: true

module Typesense
  class CurationSets
    RESOURCE_PATH = '/curation_sets'

    def initialize(api_call)
      @api_call = api_call
    end

    # Create or update a curation set with the given name
    #
    # @example
    #   client.curation_sets.upsert('my-set', 'items' => [{ 'id' => 'promote-hat', 'rule' => { 'query' => 'hat', 'match' => 'exact' } }])
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def upsert(curation_set_name, curation_set_data)
      @api_call.put("#{self.class::RESOURCE_PATH}/#{URI.encode_www_form_component(curation_set_name)}", curation_set_data)
    end

    # Retrieve all curation sets
    #
    # @example
    #   client.curation_sets.retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    def retrieve
      @api_call.get(self.class::RESOURCE_PATH)
    end

    # Access an individual curation set by name.
    #
    # @example
    #   client.curation_sets['my-set'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    #
    # @return [CurationSet]
    def [](curation_set_name)
      CurationSet.new(curation_set_name, @api_call)
    end
  end
end
