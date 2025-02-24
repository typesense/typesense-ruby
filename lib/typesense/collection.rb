# frozen_string_literal: true

module Typesense
  class Collection
    attr_reader :documents, :overrides, :synonyms

    def initialize(name, api_call)
      @name      = name
      @api_call  = api_call
      @documents = Documents.new(@name, @api_call)
      @overrides = Overrides.new(@name, @api_call)
      @synonyms  = Synonyms.new(@name, @api_call)
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def update(update_schema)
      @api_call.patch(endpoint_path, update_schema)
    end

    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Collections::RESOURCE_PATH}/#{URI.encode_www_form_component(@name)}"
    end
  end
end
