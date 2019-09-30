# frozen_string_literal: true

module Typesense
  class Overrides
    RESOURCE_PATH = '/overrides'

    def initialize(configuration, collection_name)
      @configuration   = configuration
      @collection_name = collection_name
      @overrides       = {}
    end

    def create(params)
      ApiCall.new(@configuration).put(endpoint_path, params)
    end

    def retrieve
      ApiCall.new(@configuration).get(endpoint_path)
    end

    def [](override_id)
      @overrides[override_id] ||= Override.new(@configuration, @collection_name, override_id)
    end

    private

    def endpoint_path(operation = nil)
      "#{Collections::RESOURCE_PATH}/#{@collection_name}#{Overrides::RESOURCE_PATH}#{operation.nil? ? '' : '/' + operation}"
    end
  end
end
