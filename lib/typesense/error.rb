# frozen_string_literal: true

module Typesense
  class Error < StandardError
    attr_reader :data

    def initialize(data)
      @data = data

      super
    end

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
