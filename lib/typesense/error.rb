module Typesense
  class Error
    class ObjectAlreadyExists < StandardError
    end

    class ObjectNotFound < StandardError
    end

    class ObjectUnprocessable < StandardError
    end

    class RequestMalformed < StandardError
    end

    class Unauthorized < StandardError
    end

    class ServerError < StandardError
    end
  end
end