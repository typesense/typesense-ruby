# frozen_string_literal: true

##
# These examples walk you through all the operations you can do on a collection and a document
# Search is specifically covered in another file in the examples folder

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

collection = @typesense.collections.create(schema)
ap collection

# {
#   "name"                  => "companies",
#   "fields"                => [
#     [0] {
#       "name" => "company_name",
#       "type" => "string"
#     },
#     [1] {
#       "name" => "num_employees",
#       "type" => "int32"
#     },
#     [2] {
#       "name"  => "country",
#       "type"  => "string",
#       "facet" => true
#     }
#   ],
#   "default_sorting_field" => "num_employees"
# }

##
# Retrieve a collection
sleep 0.5 # Give Typesense cluster a few hundred ms to create the collection on all nodes, before reading it right after (eventually consistent)
collection = @typesense.collections['companies'].retrieve
ap collection

# {
#   "default_sorting_field" => "num_employees",
#   "fields"                => [
#     [0] {
#       "facet" => false,
#       "name"  => "company_name",
#       "type"  => "string"
#     },
#     [1] {
#       "facet" => false,
#       "name"  => "num_employees",
#       "type"  => "int32"
#     },
#     [2] {
#       "facet" => true,
#       "name"  => "country",
#       "type"  => "string"
#     }
#   ],
#   "name"                  => "companies",
#   "num_documents"         => 0
# }

##
# Retrieve all collections
collections = @typesense.collections.retrieve
ap collections

# [
#   [0] {
#     "default_sorting_field" => "num_employees",
#     "fields"                => [
#       [0] {
#         "facet" => false,
#         "name"  => "company_name",
#         "type"  => "string"
#       },
#       [1] {
#         "facet" => false,
#         "name"  => "num_employees",
#         "type"  => "int32"
#       },
#       [2] {
#         "facet" => true,
#         "name"  => "country",
#         "type"  => "string"
#       }
#     ],
#     "name"                  => "companies",
#     "num_documents"         => 0
#   }
# ]

##
# Delete a collection
#   Deletion returns the schema of the collection after deletion
collection = @typesense.collections['companies'].delete
ap collection

# {
#   "default_sorting_field" => "num_employees",
#   "fields"                => [
#     [0] {
#       "facet" => false,
#       "name"  => "company_name",
#       "type"  => "string"
#     },
#     [1] {
#       "facet" => false,
#       "name"  => "num_employees",
#       "type"  => "int32"
#     },
#     [2] {
#       "facet" => true,
#       "name"  => "country",
#       "type"  => "string"
#     }
#   ],
#   "name"                  => "companies",
#   "num_documents"         => 0
# }

# Let's create the collection again for use in our remaining examples
@typesense.collections.create(schema)

##
# Create (index) a document
document = {
  'id' => '124',
  'company_name' => 'Stark Industries',
  'num_employees' => 5215,
  'country' => 'USA'
}

document = @typesense.collections['companies'].documents.create(document)
ap document

# {
#   "company_name"  => "Stark Industries",
#   "country"       => "USA",
#   "id"            => "124",
#   "num_employees" => 5215
# }

# You can also upsert a document, which will update the document if it already exists or create a new one if it doesn't exist
document = @typesense.collections['companies'].documents.upsert(document)
ap document

##
# Retrieve a document
sleep 0.5 # Give Typesense cluster a few hundred ms to create the document on all nodes, before reading it right after (eventually consistent)
document = @typesense.collections['companies'].documents['124'].retrieve
ap document

# {
#   "company_name"  => "Stark Industries",
#   "country"       => "USA",
#   "id"            => "124",
#   "num_employees" => 5215
# }

##
# Update a document. Unlike upsert, update will error out if the doc doesn't already exist.
document = @typesense.collections['companies'].documents['124'].update(
  'num_employees' => 5500
)
ap document

# {
#   "id"            => "124",
#   "num_employees" => 5500
# }

# This should error out, since document 145 doesn't exist
# document = @typesense.collections['companies'].documents['145'].update(
#   'num_employees' => 5500
# )
# ap document

##
# Delete a document
#   Deleting a document, returns the document after deletion
document = @typesense.collections['companies'].documents['124'].delete
ap document

# {
#   "company_name"  => "Stark Industries",
#   "country"       => "USA",
#   "id"            => "124",
#   "num_employees" => 5215
# }

# Let's bulk create two documents again for use in our remaining examples
documents = [
  {
    'id' => '124',
    'company_name' => 'Stark Industries',
    'num_employees' => 5215,
    'country' => 'USA'
  },
  {
    'id' => '125',
    'company_name' => 'Acme Corp',
    'num_employees' => 1002,
    'country' => 'France'
  }
]
ap @typesense.collections['companies'].documents.import(documents)

## If you already have documents in JSONL format, you can also pass it directly to #import, to avoid the JSON parsing overhead:
# @typesense.collections['companies'].documents.import(documents_in_jsonl_format)

## You can bulk upsert documents, by adding an upsert action option to #import
documents << {
  'id' => '126',
  'company_name' => 'Stark Industries 2',
  'num_employees' => 200,
  'country' => 'USA'
}
ap @typesense.collections['companies'].documents.import(documents, action: :upsert)

## You can bulk update documents, by adding an update action option to #import
# `action: update` will throw an error if the document doesn't already exist
# This document will error out, since id: 1200 doesn't exist
documents << {
  'id' => '1200',
  'country' => 'USA'
}
documents << {
  'id' => '126',
  'num_employees' => 300
}
ap @typesense.collections['companies'].documents.import(documents, action: :update)

## You can also bulk delete documents, using filter_by fields:
ap @typesense.collections['companies'].documents.delete(filter_by: 'num_employees:>100')

##
# Export all documents in a collection in JSON Lines format
#   We use JSON Lines format for performance reasons. You can choose to parse selected lines as needed, by splitting on \n.
sleep 0.5 # Give Typesense cluster a few hundred ms to create the document on all nodes, before reading it right after (eventually consistent)
jsonl_data = @typesense.collections['companies'].documents.export
ap jsonl_data

# "{\"company_name\":\"Stark Industries\",\"country\":\"USA\",\"id\":\"124\",\"num_employees\":5215}\n{\"company_name\":\"Acme Corp\",\"country\":\"France\",\"id\":\"125\",\"num_employees\":1002}"

##
# Cleanup
# Drop the collection
@typesense.collections['companies'].delete
