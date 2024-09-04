# frozen_string_literal: true

module Typesense
  class Preset
    def initialize(preset_name, api_call)
      @preset_name = preset_name
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
      "#{Presets::RESOURCE_PATH}/#{ERB::Util.url_encode(@preset_name)}"
    end
  end
end
