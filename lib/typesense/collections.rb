module Typesense
  class Collections
    ENDPOINT_PATH = '/collections'

    def initialize(configuration, name = nil)
      @configuration = configuration
      @name          = name
      @documents     = {}
    end

    def create(schema)
      validate_absence_of_collection_name! __method__
      ApiCall.new(@configuration).post(ENDPOINT_PATH, schema)
    end

    def retrieve
      ApiCall.new(@configuration).get("#{ENDPOINT_PATH}/#{@name}")
    end

    def delete
      ApiCall.new(@configuration).delete("#{ENDPOINT_PATH}/#{@name}")
    end

    def retrieve_all
      validate_absence_of_collection_name! __method__
      ApiCall.new(@configuration).get("#{ENDPOINT_PATH}")
    end

    def documents(document_id = nil)
      validate_presence_of_collection_name! __method__

      @documents[document_id] ||= Documents.new(@configuration, @name, document_id)
    end

    private
    def validate_absence_of_collection_name!(method)
      if !@name.nil?
        raise Error::NoMethodError.new("##{method} cannot be called on a specific collection")
      end
    end

    def validate_presence_of_collection_name!(method)
      if @name.nil?
        raise Error::NoMethodError.new("##{method} needs to be called on a specific collection")
      end
    end
  end
end
