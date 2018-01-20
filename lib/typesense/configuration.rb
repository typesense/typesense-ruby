module Typesense
  class Configuration
    attr_accessor :host, :port, :protocol, :api_key

    def initialize
      self.host     = 'localhost'
      self.port     = 8108
      self.protocol = 'http'
      self.api_key  = 'abcd'
    end
  end
end