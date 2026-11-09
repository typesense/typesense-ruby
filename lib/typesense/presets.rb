# frozen_string_literal: true

module Typesense
  class Presets
    RESOURCE_PATH = '/presets'

    def initialize(api_call)
      @api_call = api_call
      @presets = {}
    end

    # Create or update an existing preset.
    #
    # @example
    #   client.presets.upsert('listing_view', 'value' => { 'q' => '*' })
    #
    # @see https://typesense.org/docs/latest/api/search.html#presets
    def upsert(preset_name, params)
      @api_call.put(endpoint_path(preset_name), params)
    end

    # Retrieve the details of all presets
    #
    # @example
    #   client.presets.retrieve
    #
    # @see https://typesense.org/docs/latest/api/search.html#presets
    def retrieve
      @api_call.get(endpoint_path)
    end

    # Access an individual preset by ID.
    #
    # @example
    #   client.presets['listing_view'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/search.html#presets
    #
    # @return [Preset]
    def [](preset_name)
      @presets[preset_name] ||= Preset.new(preset_name, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{Presets::RESOURCE_PATH}#{"/#{URI.encode_www_form_component(operation)}" unless operation.nil?}"
    end
  end
end
