# frozen_string_literal: true

module Typesense
  class NlSearchModel
    def initialize(model_id, api_call)
      @model_id = model_id
      @api_call = api_call
    end

    # Retrieve a specific NL search model by its ID.
    #
    # @example
    #   client.nl_search_models['model-1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/natural-language-search.html
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Update an existing NL search model.
    #
    # @example
    #   client.nl_search_models['model-1'].update('model_name' => 'openai/gpt-4')
    #
    # @see https://typesense.org/docs/latest/api/natural-language-search.html
    def update(update_schema)
      @api_call.put(endpoint_path, update_schema)
    end

    # Delete a specific NL search model by its ID.
    #
    # @example
    #   client.nl_search_models['model-1'].delete
    #
    # @see https://typesense.org/docs/latest/api/natural-language-search.html
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{NlSearchModels::RESOURCE_PATH}/#{URI.encode_www_form_component(@model_id)}"
    end
  end
end
