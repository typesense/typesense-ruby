# frozen_string_literal: true

module Typesense
  class Key
    def initialize(id, api_call)
      @id = id
      @api_call = api_call
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Keys::RESOURCE_PATH}/#{@id}"
    end
  end
end
