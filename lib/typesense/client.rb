module Typesense
  class Client
    attr_accessor :configuration

    def initialize(configuration = {})
      @configuration ||= Configuration.new(configuration)
      @collections   = {}
      @debug         = Debug.new(configuration)
    end

    def collections(collection_name = nil)
      @collections[collection_name] ||= Collections.new(configuration, collection_name)
    end

    def debug
      @debug
    end
  end
end