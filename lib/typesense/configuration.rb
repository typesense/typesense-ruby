module Typesense
  class Configuration
    attr_accessor :host, :protocol, :api_key

    def initialize
      self.host     = 'localhost:8108'
      self.protocol = 'http'
      self.api_key  = 'abcd'
    end
  end
end