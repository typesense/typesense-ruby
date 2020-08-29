# frozen_string_literal: true

module Typesense
  class Overrides
    RESOURCE_PATH = '/overrides'

    def initialize(collection_name, api_call)
      @collection_name = collection_name
      @api_call        = api_call
      @overrides       = {}
    end

    def create(params)
      @api_call.put(endpoint_path, params)
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def [](override_id)
      @overrides[override_id] ||= Override.new(@collection_name, override_id, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{Collections::RESOURCE_PATH}/#{@collection_name}#{Overrides::RESOURCE_PATH}#{operation.nil? ? '' : "/#{operation}"}"
    end
  end
end
