module Typesense
  class Debug
    ENDPOINT_PATH = '/debug'

    def initialize(configuration)
      @configuration = configuration
    end

    def retrieve
      ApiCall.new(@configuration).get(ENDPOINT_PATH)
    end
  end
end