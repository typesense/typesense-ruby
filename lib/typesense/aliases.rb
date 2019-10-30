# frozen_string_literal: true

module Typesense
  class Aliases
    RESOURCE_PATH = '/aliases'

    def initialize(configuration)
      @configuration = configuration
      @aliases = {}
    end

    def upsert(alias_name, mapping)
      ApiCall.new(@configuration).put(endpoint_path(alias_name), mapping)
    end

    def retrieve
      ApiCall.new(@configuration).get(RESOURCE_PATH)
    end

    def [](alias_name)
      @aliases[alias_name] ||= Alias.new(@configuration, alias_name)
    end

    private

    def endpoint_path(alias_name)
      "#{Aliases::RESOURCE_PATH}/#{alias_name}"
    end
  end
end
