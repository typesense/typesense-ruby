# frozen_string_literal: true

module Typesense
  class Alias
    def initialize(configuration, name)
      @configuration = configuration
      @name          = name
    end

    def retrieve
      ApiCall.new(@configuration).get(endpoint_path)
    end

    def delete
      ApiCall.new(@configuration).delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Aliases::RESOURCE_PATH}/#{@name}"
    end
  end
end
