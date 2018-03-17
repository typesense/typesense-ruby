module Typesense
  class Debug
    RESOURCE_PATH = '/debug'

    def initialize(configuration)
      @configuration = configuration
    end

    def retrieve
      ApiCall.new(@configuration).get(RESOURCE_PATH)
    end
  end
end