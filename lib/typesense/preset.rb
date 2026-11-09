# frozen_string_literal: true

module Typesense
  class Preset
    def initialize(preset_name, api_call)
      @preset_name = preset_name
      @api_call = api_call
    end

    # Retrieve the details of a preset, given it's name.
    #
    # @example
    #   client.presets['listing_view'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/search.html#presets
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Permanently deletes a preset, given it's name.
    #
    # @example
    #   client.presets['listing_view'].delete
    #
    # @see https://typesense.org/docs/latest/api/search.html#presets
    def delete
      @api_call.delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Presets::RESOURCE_PATH}/#{URI.encode_www_form_component(@preset_name)}"
    end
  end
end
