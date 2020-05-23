# frozen_string_literal: true

module Typesense
  class Aliases
    RESOURCE_PATH = '/aliases'

    def initialize(api_call)
      @api_call = api_call
      @aliases = {}
    end

    def upsert(alias_name, mapping)
      @api_call.put(endpoint_path(alias_name), mapping)
    end

    def retrieve
      @api_call.get(RESOURCE_PATH)
    end

    def [](alias_name)
      @aliases[alias_name] ||= Alias.new(alias_name, @api_call)
    end

    private

    def endpoint_path(alias_name)
      "#{Aliases::RESOURCE_PATH}/#{alias_name}"
    end
  end
end
