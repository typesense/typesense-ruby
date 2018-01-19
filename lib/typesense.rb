module Typesense
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end
end

require 'typesense/version'
require 'typesense/configuration'
require 'typesense/api_call'
require 'typesense/collections'
require 'typesense/documents'