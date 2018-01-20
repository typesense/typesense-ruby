module Typesense
  class Debug
    ENDPOINT_PATH = '/debug'

    class << self
      def retrieve
        ApiCall.new.get(ENDPOINT_PATH)
      end
    end
  end
end