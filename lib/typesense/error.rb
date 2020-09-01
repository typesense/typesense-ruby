# frozen_string_literal: true

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

    class HTTPStatus0Error < Error
    end

    class TimeoutError < Error
    end

    class NoMethodError < ::NoMethodError
    end

    class HTTPError < Error
    end
  end
end
