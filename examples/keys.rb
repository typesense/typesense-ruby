# frozen_string_literal: true

##
# These examples walk you through operations to manage API Keys

require_relative './client_initialization'

# Let's setup some test data for this example
schema = {
  'name' => 'users',
  'fields' => [
    {
      'name' => 'company_id',
      'type' => 'int32',
      'facet' => false
    },
    {
      'name' => 'user_name',
      'type' => 'string',
      'facet' => false
    },
    {
      'name' => 'login_count',
      'type' => 'int32',
      'facet' => false
    },
    {
      'name' => 'country',
      'type' => 'string',
      'facet' => true
    }
  ],
  'default_sorting_field' => 'company_id'
}

# We have four users, belonging to two companies: 124 and 126
documents = [
  {
    'company_id' => 124,
    'user_name' => 'Hilary Bradford',
    'login_count' => 10,
    'country' => 'USA'
  },
  {
    'company_id' => 124,
    'user_name' => 'Nile Carty',
    'login_count' => 100,
    'country' => 'USA'
  },
  {
    'company_id' => 126,
    'user_name' => 'Tahlia Maxwell',
    'login_count' => 1,
    'country' => 'France'
  },
  {
    'company_id' => 126,
    'user_name' => 'Karl Roy',
    'login_count' => 2,
    'country' => 'Germany'
  }
]

# Delete if the collection already exists from a previous example run
begin
  @typesense.collections['users'].delete
rescue Typesense::Error::ObjectNotFound
end

# create a collection
@typesense.collections.create(schema)

# Index documents
documents.each do |document|
  @typesense.collections['users'].documents.create(document)
end

# Generate an API key and restrict it to only allow searches
# You want to use this API Key in the browser instead of the master API Key
unscoped_search_only_api_key_response = @typesense.keys.create({
                                                                 'description' => 'Search-only key.',
                                                                 'actions' => ['documents:search'],
                                                                 'collections' => ['*']
                                                               })
ap unscoped_search_only_api_key_response

# Save the key returned, since this will be the only time the full API Key is returned, for security purposes
unscoped_search_only_api_key = unscoped_search_only_api_key_response['value']

# Side note: you can also retrieve metadata of API keys using the ID returned in the above response
unscoped_search_only_api_key_response = @typesense.keys[unscoped_search_only_api_key_response['id']].retrieve
ap unscoped_search_only_api_key_response

# We'll now use this search-only API key to generate a scoped search API key that can only access documents that have company_id:124
#  This is useful when you store multi-tenant data in a single Typesense server, but you only want
#  a particular tenant to access their own data. You'd generate one scoped search key per tenant.
#  IMPORTANT: scoped search keys should only be generated *server-side*, so as to not leak the unscoped main search key to clients
scoped_search_only_api_key = @typesense.keys.generate_scoped_search_key(unscoped_search_only_api_key, { 'filter_by': 'company_id:124' })
ap "scoped_search_only_api_key: #{scoped_search_only_api_key}"

# Now let's search the data using the scoped API Key for company_id:124
# You can do searches with this scoped_search_only_api_key from the server-side or client-side
scoped_typesense_client = Typesense::Client.new({
                                                  'nodes': [{
                                                    'host': 'localhost',
                                                    'port': '8108',
                                                    'protocol': 'http'
                                                  }],
                                                  'api_key': scoped_search_only_api_key
                                                })

search_results = scoped_typesense_client.collections['users'].documents.search({
                                                                                 'q' => 'Hilary',
                                                                                 'query_by' => 'user_name'
                                                                               })
ap search_results

# Search for a user that exists, but is outside the current key's scope
search_results = scoped_typesense_client.collections['users'].documents.search({
                                                                                 'q': 'Maxwell',
                                                                                 'query_by': 'user_name'
                                                                               })
ap search_results # Will return empty result set

# Now let's delete the unscoped_search_only_api_key. You'd want to do this when you need to rotate keys for example.
results = @typesense.keys[unscoped_search_only_api_key_response['id']].delete
ap results
