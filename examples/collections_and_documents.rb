# frozen_string_literal: true

##
# These examples walk you through all the operations you can do on a collection and a document
# Search is specifically covered in another file in the examples folder

require_relative '../lib/typesense'
require 'awesome_print'

AwesomePrint.defaults = {
  indent: -2
}

##
# Setup
#
# Start the master
#   $ docker run -p 8108:8108  -it -v/tmp/typesense-data-master/:/data -it typesense/typesense:0.8.0-rc1 --data-dir /data --api-key=abcd --listen-port 8108
#
# Start the read replica
#   $ docker run -p 8109:8109  -it -v/tmp/typesense-data-read-replica-1/:/data -it typesense/typesense:0.8.0-rc1 --data-dir /data --api-key=wxyz --listen-port 8109 --master http://localhost:8108

##
# Create a client
typesense = Typesense::Client.new(
  master_node: {
    host: 'localhost',
    port: 8108,
    protocol: 'http',
    api_key: 'abcd'
  },
  read_replica_nodes: [
    {
      host: 'localhost',
      port: 8109,
      protocol: 'http',
      api_key: 'wxyz'
    }
  ],
  timeout_seconds: 10
)

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

collection = typesense.collections.create(schema)
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
collection = typesense.collections['companies'].retrieve
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
collections = typesense.collections.retrieve
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
collection = typesense.collections['companies'].delete
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
typesense.collections.create(schema)

##
# Create (index) a document
document = {
  'id' => '124',
  'company_name' => 'Stark Industries',
  'num_employees' => 5215,
  'country' => 'USA'
}

document = typesense.collections['companies'].documents.create(document)
ap document

# {
#   "company_name"  => "Stark Industries",
#   "country"       => "USA",
#   "id"            => "124",
#   "num_employees" => 5215
# }

##
# Retrieve a document
document = typesense.collections['companies'].documents['124'].retrieve
ap document

# {
#   "company_name"  => "Stark Industries",
#   "country"       => "USA",
#   "id"            => "124",
#   "num_employees" => 5215
# }

##
# Delete a document
#   Deleting a document, returns the document after deletion
document = typesense.collections['companies'].documents['124'].delete
ap document

# {
#   "company_name"  => "Stark Industries",
#   "country"       => "USA",
#   "id"            => "124",
#   "num_employees" => 5215
# }

# Let's create two documents again for use in our remaining examples
typesense.collections['companies'].documents.create(
  'id' => '124',
  'company_name' => 'Stark Industries',
  'num_employees' => 5215,
  'country' => 'USA'
)

typesense.collections['companies'].documents.create(
  'id' => '125',
  'company_name' => 'Acme Corp',
  'num_employees' => 1002,
  'country' => 'France'
)

##
# Export all documents in a collection in JSON Lines format
#   We use JSON Lines format for performance reasons. You can choose to parse selected lines (elements in the array) as needed.
array_of_json_strings = typesense.collections['companies'].documents.export
ap array_of_json_strings

# [
# [0] "{\"company_name\":\"Stark Industries\",\"country\":\"USA\",\"id\":\"124\",\"num_employees\":5215}",
# [1] "{\"company_name\":\"Acme Corp\",\"country\":\"France\",\"id\":\"125\",\"num_employees\":1002}"
# ]

##
# Cleanup
# Drop the collection
typesense.collections['companies'].delete
