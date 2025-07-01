# frozen_string_literal: true

module Typesense
  class Client
    attr_reader :configuration, :collections, :aliases, :keys, :debug, :health, :metrics, :stats, :operations,
                :multi_search, :analytics, :presets, :stemming, :nl_search_models

    def initialize(options = {})
      @configuration = Configuration.new(options)
      @api_call = ApiCall.new(@configuration)
      @collections = Collections.new(@api_call)
      @aliases = Aliases.new(@api_call)
      @keys = Keys.new(@api_call)
      @multi_search = MultiSearch.new(@api_call)
      @debug = Debug.new(@api_call)
      @health = Health.new(@api_call)
      @metrics = Metrics.new(@api_call)
      @stats = Stats.new(@api_call)
      @operations = Operations.new(@api_call)
      @analytics = Analytics.new(@api_call)
      @stemming = Stemming.new(@api_call)
      @presets = Presets.new(@api_call)
      @nl_search_models = NlSearchModels.new(@api_call)
    end
  end
end
