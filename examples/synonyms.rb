# frozen_string_literal: true

##
# These examples walk you through operations specifically related to synonyms

require_relative './client_initialization'

# Delete the collection if it already exists
begin
  @typesense.collections['companies'].delete
rescue Typesense::Error::ObjectNotFound
end

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
# Create synonyms

ap @typesense.collections['companies'].synonyms.upsert(
  'synonyms-doofenshmirtz',
  {
    'synonyms' => %w[Doofenshmirtz Heinz Evil]
  }
)

##
# Search for documents
# Should return Doofenshmirtz Inc, since it's set as a synonym
results = @typesense.collections['companies'].documents.search(
  'q' => 'Heinz',
  'query_by' => 'company_name'
)
ap results

##
# List all synonyms
ap @typesense.collections['companies'].synonyms.retrieve

##
# Retrieve specific synonym
ap @typesense.collections['companies'].synonyms['synonyms-doofenshmirtz'].retrieve

##
# Update synonym to a one-way synonym
ap @typesense.collections['companies'].synonyms.upsert(
  'synonyms-doofenshmirtz',
  {
    'root' => 'Evil',
    'synonyms' => %w[Doofenshmirtz Heinz]
  }
)

##
# Search for documents
# Should return Doofenshmirtz Inc, since it's set as a synonym
results = @typesense.collections['companies'].documents.search(
  'q' => 'Evil',
  'query_by' => 'company_name'
)
ap results

# Should not return any results, since this is a one-way synonym
results = @typesense.collections['companies'].documents.search(
  'q' => 'Heinz',
  'query_by' => 'company_name'
)
ap results

##
# Delete synonym
ap @typesense.collections['companies'].synonyms['synonyms-doofenshmirtz'].delete

##
# Cleanup
# Drop the collection
@typesense.collections['companies'].delete
