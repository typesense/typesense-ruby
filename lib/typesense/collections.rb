module Typesense
  class Collections
    ENDPOINT_PATH = '/collections'

    def self.create(schema)
      ApiCall.new.post(ENDPOINT_PATH, schema)
    end
  end
end