# frozen_string_literal: true

module Typesense
  class Stemming
    RESOURCE_PATH = '/stemming'

    def initialize(api_call)
      @api_call = api_call
    end

    # Access the stemming dictionaries resource. Use it to list or import dictionaries, or as an array
    # to access a single dictionary by ID.
    #
    # @example
    #   client.stemming.dictionaries.retrieve
    # @example
    #   client.stemming.dictionaries['en'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/stemming.html
    #
    # @return [StemmingDictionaries]
    def dictionaries
      @dictionaries ||= StemmingDictionaries.new(@api_call)
    end
  end
end
