module Typesense
  class Configuration
    attr_accessor :host, :port, :protocol, :api_key

    def initialize
      self.host     = 'localhost'
      self.port     = 8108
      self.protocol = 'http'
    end
  end
end