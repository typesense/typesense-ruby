module Typesense
  class Error < StandardError
    class MissingConfiguration < Error
    end

    class ObjectAlreadyExists < Error
    end

    class ObjectNotFound < Error
    end

    class ObjectUnprocessable < Error
    end

    class RequestMalformed < Error
    end

    class RequestUnauthorized < Error
    end

    class ServerError < Error
    end
  end
end