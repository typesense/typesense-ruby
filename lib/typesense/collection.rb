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
      ApiCall.new(@configuration).get(uri)
    end

    def delete
      ApiCall.new(@configuration).delete(uri)
    end

    private

    def uri
      "#{Collections::RESOURCE_PATH}/#{@name}"
    end
  end
end
