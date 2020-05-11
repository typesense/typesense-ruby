# frozen_string_literal: true

##
# These examples walk you through operations specifically related to overrides
# This is a Typesense Premium feature (see: https://typesense.org/premium)
# Be sure to add `--license-key=<>` as a parameter, when starting a Typesense Premium server

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
# Create overrides

@typesense.collections['companies'].overrides.create(
  "id": 'promote-doofenshmirtz',
  "rule": {
    "query": 'doofen',
    "match": 'exact'
  },
  "includes": [{ 'id' => '126', 'position' => 1 }]
)
@typesense.collections['companies'].overrides.create(
  "id": 'promote-acme',
  "rule": {
    "query": 'stark',
    "match": 'exact'
  },
  "includes": [{ 'id' => '125', 'position' => 1 }]
)

##
# Search for documents
results = @typesense.collections['companies'].documents.search(
  'q' => 'doofen',
  'query_by' => 'company_name'
)
ap results

results = @typesense.collections['companies'].documents.search(
  'q' => 'stark',
  'query_by' => 'company_name'
)
ap results

results = @typesense.collections['companies'].documents.search(
  'q' => 'Inc',
  'query_by' => 'company_name',
  'filter_by' => 'num_employees:<100',
  'sort_by' => 'num_employees:desc'
)
ap results

##
# Cleanup
# Drop the collection
@typesense.collections['companies'].delete
