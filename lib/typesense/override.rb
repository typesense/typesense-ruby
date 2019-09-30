# frozen_string_literal: true

module Typesense
  class Override
    def initialize(configuration, collection_name, override_id)
      @configuration   = configuration
      @collection_name = collection_name
      @override_id     = override_id
    end

    def retrieve
      ApiCall.new(@configuration).get(endpoint_path)
    end

    def delete
      ApiCall.new(@configuration).delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Collections::RESOURCE_PATH}/#{@collection_name}#{Overrides::RESOURCE_PATH}/#{@override_id}"
    end
  end
end
