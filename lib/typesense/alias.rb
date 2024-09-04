# frozen_string_literal: true

module Typesense
  class Alias
    def initialize(name, api_call)
      @name     = name
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
      "#{Aliases::RESOURCE_PATH}/#{ERB::Util.url_encode(@name)}"
    end
  end
end
