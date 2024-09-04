# frozen_string_literal: true

module Typesense
  class Presets
    RESOURCE_PATH = '/presets'

    def initialize(api_call)
      @api_call = api_call
      @presets = {}
    end

    def upsert(preset_name, params)
      @api_call.put(endpoint_path(preset_name), params)
    end

    def retrieve
      @api_call.get(endpoint_path)
    end

    def [](preset_name)
      @presets[preset_name] ||= Preset.new(preset_name, @api_call)
    end

    private

    def endpoint_path(operation = nil)
      "#{Presets::RESOURCE_PATH}#{operation.nil? ? '' : "/#{ERB::Util.url_encode(operation)}"}"
    end
  end
end
