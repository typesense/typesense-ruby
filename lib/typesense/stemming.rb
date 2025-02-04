# frozen_string_literal: true
module Typesense
  class Stemming
    RESOURCE_PATH = "/stemming"

    def initialize(api_call)
      @api_call = api_call
    end

    def dictionaries
      @dictionaries ||= StemmingDictionaries.new(@api_call)
    end
  end
end
