# frozen_string_literal: true

module Typesense
  class Client
    attr_reader :configuration
    attr_reader :collections
    attr_reader :aliases
    attr_reader :debug

    def initialize(options = {})
      @configuration = Configuration.new(options)
      @api_call = ApiCall.new(@configuration)
      @collections = Collections.new(@api_call)
      @aliases = Aliases.new(@api_call)
      @debug = Debug.new(@api_call)
    end
  end
end
