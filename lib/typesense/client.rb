# frozen_string_literal: true

module Typesense
  class Client
    attr_reader :configuration
    attr_reader :collections
    attr_reader :debug

    def initialize(options = {})
      @configuration ||= Configuration.new(options)
      @collections   = Collections.new(@configuration)
      @debug         = Debug.new(@configuration)
    end
  end
end
