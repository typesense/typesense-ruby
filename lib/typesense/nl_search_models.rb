# frozen_string_literal: true

module Typesense
  class NlSearchModels
    RESOURCE_PATH = '/nl_search_models'

    def initialize(api_call)
      @api_call = api_call
      @nl_search_models = {}
    end

    # Create a new NL search model.
    #
    # @example
    #   client.nl_search_models.create('model_name' => 'openai/gpt-4', 'api_key' => '...')
    #
    # @see https://typesense.org/docs/latest/api/natural-language-search.html
    def create(schema)
      @api_call.post(RESOURCE_PATH, schema)
    end

    # Retrieve all NL search models.
    #
    # @example
    #   client.nl_search_models.retrieve
    #
    # @see https://typesense.org/docs/latest/api/natural-language-search.html
    def retrieve
      @api_call.get(RESOURCE_PATH)
    end

    # Access an individual NL search model by ID.
    #
    # @example
    #   client.nl_search_models['model-1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/natural-language-search.html
    #
    # @return [NlSearchModel]
    def [](model_id)
      @nl_search_models[model_id] ||= NlSearchModel.new(model_id, @api_call)
    end
  end
end
