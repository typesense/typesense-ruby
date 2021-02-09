# frozen_string_literal: true

##
# These examples walk you through operations specifically related to search

require_relative './client_initialization'

##
# Create a collection
schema = {
  'name' => 'companies',
  'fields' => [
    {
      'name' => 'company_name',
      'type' => 'string'
    },
    {
      'name' => 'num_employees',
      'type' => 'int32'
    },
    {
      'name' => 'country',
      'type' => 'string',
      'facet' => true
    }
  ],
  'default_sorting_field' => 'num_employees'
}

# Delete the collection if it already exists
begin
  @typesense.collections['companies'].delete
rescue Typesense::Error::ObjectNotFound
end

# Now create the collection
@typesense.collections.create(schema)

# Let's create a couple documents for us to use in our search examples
@typesense.collections['companies'].documents.create(
  'id' => '124',
  'company_name' => 'Stark Industries',
  'num_employees' => 5215,
  'country' => 'USA'
)

@typesense.collections['companies'].documents.create(
  'id' => '127',
  'company_name' => 'Stark Corp',
  'num_employees' => 1031,
  'country' => 'USA'
)

@typesense.collections['companies'].documents.create(
  'id' => '125',
  'company_name' => 'Acme Corp',
  'num_employees' => 1002,
  'country' => 'France'
)

@typesense.collections['companies'].documents.create(
  'id' => '126',
  'company_name' => 'Doofenshmirtz Inc',
  'num_employees' => 2,
  'country' => 'Tri-State Area'
)

##
# Search for documents
results = @typesense.collections['companies'].documents.search(
  'q' => 'Stark',
  'query_by' => 'company_name'
)
ap results

##
# Search for more documents
results = @typesense.collections['companies'].documents.search(
  'q' => 'Inc',
  'query_by' => 'company_name',
  'filter_by' => 'num_employees:<100',
  'sort_by' => 'num_employees:desc'
)
ap results

##
# Search for more multiple documents
results = @typesense.multi_search.perform(
  {
    searches: [
      {
        'q' => 'Inc',
        'filter_by' => 'num_employees:<100',
        'sort_by' => 'num_employees:desc'
      },
      {
        'q' => 'Stark',
      }
    ]
  },
  {
    # Parameters that are common to all searches, can be mentioned here
    'collection' => 'companies',
    'query_by' => 'company_name'
  }
)
ap results

##
# Search for more documents
results = @typesense.collections['companies'].documents.search(
  'q' => 'Non-existent',
  'query_by' => 'company_name'
)
ap results

##
# Cleanup
# Drop the collection
@typesense.collections['companies'].delete
