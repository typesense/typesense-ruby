# frozen_string_literal: true

module Typesense
  # Typesense client for indexing, searching, and managing collections.
  #
  # @see https://typesense.org/docs/latest/api/
  class Client
    # @return [Configuration]
    attr_reader :configuration

    # Access the collections resource. Use it to list or create collections, or as an array to access a single collection by name.
    #
    # @example
    #   client.collections.create('name' => 'products', 'fields' => [{ 'name' => 'title', 'type' => 'string' }])
    # @example
    #   client.collections['products'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/collections.html
    #
    # @return [Collections]
    attr_reader :collections

    # Access the aliases resource. Use it to upsert or list aliases, or as an array to access a single alias by name.
    #
    # @example
    #   client.aliases.upsert('my-alias', 'collection_name' => 'products')
    # @example
    #   client.aliases['my-alias'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/collection-alias.html
    #
    # @return [Aliases]
    attr_reader :aliases

    # Access the API keys resource. Use it to create or list keys, or as an array to access a single key by ID.
    #
    # @example
    #   client.keys.create('description' => 'Search-only key', 'actions' => ['documents:search'], 'collections' => ['*'])
    # @example
    #   client.keys[1].retrieve
    #
    # @see https://typesense.org/docs/latest/api/api-keys.html
    #
    # @return [Keys]
    attr_reader :keys

    # Retrieve server version and state information.
    #
    # @example
    #   client.debug.retrieve
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html#debug
    #
    # @return [Debug]
    attr_reader :debug

    # Checks if Typesense server is ready to accept requests.
    #
    # @example
    #   client.health.retrieve
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html#health
    #
    # @return [Health]
    attr_reader :health

    # Get current RAM, CPU, Disk & Network usage metrics.
    #
    # @example
    #   client.metrics.retrieve
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html
    #
    # @return [Metrics]
    attr_reader :metrics

    # Get stats about API endpoints.
    #
    # @example
    #   client.stats.retrieve
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html
    #
    # @return [Stats]
    attr_reader :stats

    # Cluster operations: snapshots, voting, cache, on-disk compaction, slow request log.
    #
    # @example
    #   client.operations.perform('snapshot', 'snapshot_path' => '/tmp/snap')
    #
    # @see https://typesense.org/docs/latest/api/cluster-operations.html
    #
    # @return [Operations]
    attr_reader :operations

    # Send multiple search requests in a single HTTP request.
    #
    # @example
    #   client.multi_search.perform('searches' => [{ 'collection' => 'products', 'q' => '*' }])
    #
    # @see https://typesense.org/docs/latest/api/documents.html#federated-multi-search
    #
    # @return [MultiSearch]
    attr_reader :multi_search

    # Manage analytics rules and events.
    #
    # @example
    #   client.analytics.rules.retrieve
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    #
    # @return [Analytics]
    attr_reader :analytics

    # Legacy v1 analytics API for rules and events.
    #
    # @example
    #   client.analytics_v1.rules.retrieve
    #
    # @see https://typesense.org/docs/latest/api/analytics-query-suggestions.html
    #
    # @return [AnalyticsV1]
    attr_reader :analytics_v1

    # Access the presets resource. Use it to upsert or list presets, or as an array to access a single preset by name.
    #
    # @example
    #   client.presets.upsert('listing_view', 'value' => { 'q' => '*' })
    # @example
    #   client.presets['listing_view'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/search.html#presets
    #
    # @return [Presets]
    attr_reader :presets

    # Manage stemming dictionaries.
    #
    # @example
    #   client.stemming.dictionaries.retrieve
    #
    # @see https://typesense.org/docs/latest/api/stemming.html
    #
    # @return [Stemming]
    attr_reader :stemming

    # Access the NL search models resource. Use it to create or list models, or as an array to access a single model by ID.
    #
    # @example
    #   client.nl_search_models.create('model_name' => 'openai/gpt-4')
    # @example
    #   client.nl_search_models['model-1'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/natural-language-search.html
    #
    # @return [NlSearchModels]
    attr_reader :nl_search_models

    # Access the synonym sets resource. Use it to upsert or list sets, or as an array to access a single set by name.
    #
    # @example
    #   client.synonym_sets.retrieve
    # @example
    #   client.synonym_sets['my-set'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/synonyms.html
    #
    # @return [SynonymSets]
    attr_reader :synonym_sets

    # Access the curation sets resource. Use it to upsert or list sets, or as an array to access a single set by name.
    #
    # @example
    #   client.curation_sets.retrieve
    # @example
    #   client.curation_sets['my-set'].retrieve
    #
    # @see https://typesense.org/docs/latest/api/curation.html
    #
    # @return [CurationSets]
    attr_reader :curation_sets

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
      @analytics_v1 = AnalyticsV1.new(@api_call)
      @stemming = Stemming.new(@api_call)
      @presets = Presets.new(@api_call)
      @nl_search_models = NlSearchModels.new(@api_call)
      @synonym_sets = SynonymSets.new(@api_call)
      @curation_sets = CurationSets.new(@api_call)
    end
  end
end
