# frozen_string_literal: true

module Typesense
  class StemmingDictionaries
    RESOURCE_PATH = '/stemming/dictionaries'

    def initialize(api_call)
      @api_call = api_call
      @dictionaries = {}
    end

    def upsert(dict_id, words_and_roots_combinations)
      words_and_roots_combinations_in_jsonl = if words_and_roots_combinations.is_a?(Array)
                                                words_and_roots_combinations.map { |combo| JSON.dump(combo) }.join("\n")
                                              else
                                                words_and_roots_combinations
                                              end

      result_in_jsonl = @api_call.perform_request(
        'post',
        endpoint_path('import'),
        query_parameters: { id: dict_id },
        body_parameters: words_and_roots_combinations_in_jsonl,
        additional_headers: { 'Content-Type' => 'text/plain' }
      )

      if words_and_roots_combinations.is_a?(Array)
        result_in_jsonl.split("\n").map { |r| JSON.parse(r) }
      else
        result_in_jsonl
      end
    end

    def retrieve
      response = @api_call.get(endpoint_path)
      response || { 'dictionaries' => [] }
    end

    def [](dict_id)
      @dictionaries[dict_id] ||= StemmingDictionary.new(dict_id, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{StemmingDictionaries::RESOURCE_PATH}#{"/#{URI.encode_www_form_component(operation)}" unless operation.nil?}"
    end
  end
end
