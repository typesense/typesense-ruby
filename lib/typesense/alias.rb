# frozen_string_literal: true

module Typesense
  class Alias
    def initialize(name, api_call)
      @name     = name
      @api_call = api_call
    end

    # Find out which collection an alias points to by fetching it
    #
    # @example
    #   client.aliases['my-alias'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/collection-alias.html#retrieve-an-alias
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Delete an alias
    #
    # @example
    #   client.aliases['my-alias'].delete
    #
    # @see https://typesense.org/docs/latest/api/collection-alias.html#delete-an-alias
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Aliases::RESOURCE_PATH}/#{URI.encode_www_form_component(@name)}"
    end
  end
end
