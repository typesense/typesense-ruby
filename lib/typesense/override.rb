# frozen_string_literal: true

module Typesense
  class Override
    def initialize(collection_name, override_id, api_call)
      @collection_name = collection_name
      @override_id     = override_id
      @api_call        = api_call
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Collections::RESOURCE_PATH}/#{ERB::Util.url_encode(@collection_name)}#{Overrides::RESOURCE_PATH}/#{ERB::Util.url_encode(@override_id)}"
    end
  end
end
