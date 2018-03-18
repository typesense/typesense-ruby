# frozen_string_literal: true

module Typesense
  class Collection
    attr_reader :documents

    def initialize(configuration, name)
      @configuration = configuration
      @name          = name
      @documents     = Documents.new(@configuration, @name)
    end

    def retrieve
      ApiCall.new(@configuration).get(endpoint_path)
    end

    def delete
      ApiCall.new(@configuration).delete(endpoint_path)
    end

    private

    def endpoint_path
      "#{Collections::RESOURCE_PATH}/#{@name}"
    end
  end
end
