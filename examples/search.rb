# frozen_string_literal: true

##
# These examples walk you through operations specifically related to search

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
  master_node:        {
    host:     'localhost',
    port:     8108,
    protocol: 'http',
    api_key:  'abcd'
  },
  read_replica_nodes: [
    {
      host:     'localhost',
      port:     8109,
      protocol: 'http',
      api_key:  'wxyz'
    }
  ],
  timeout_seconds:    10
)

##
# Create a collection
schema = {
  'name'      => 'companies',
  'fields'    => [
    {
      'name' => 'company_name',
      'type' => 'string'
    },
    {
      'name'  => 'num_employees',
      'type'  => 'int32'
    },
    {
      'name'  => 'country',
      'type'  => 'string',
      'facet' => true
    }
  ],
  'default_sorting_field' => 'num_employees'
}

typesense.collections.create(schema)

# Let's create a couple documents for us to use in our search examples
typesense.collections['companies'].documents.create(
  'id' => '124',
  'company_name' => 'Stark Industries',
  'num_employees' => 5215,
  'country' => 'USA'
)

typesense.collections['companies'].documents.create(
  'id' => '127',
  'company_name' => 'Stark Corp',
  'num_employees' => 1031,
  'country' => 'USA'
)

typesense.collections['companies'].documents.create(
  'id' => '125',
  'company_name' => 'Acme Corp',
  'num_employees' => 1002,
  'country' => 'France'
)

typesense.collections['companies'].documents.create(
  'id' => '126',
  'company_name' => 'Doofenshmirtz Inc',
  'num_employees' => 2,
  'country' => 'Tri-State Area'
)

##
# Search for documents
results = typesense.collections['companies'].documents.search(
  'q' => 'Stark',
  'query_by' => 'company_name'
)
ap results

# {
#   "facet_counts"   => [],
#   "found"          => 2,
#   "hits"           => [
#     [0] {
#       "document"  => {
#         "company_name"  => "Stark Industries",
#         "country"       => "USA",
#         "id"            => "124",
#         "num_employees" => 5215
#       },
#       "highlight" => {
#         "company_name" => "<mark>Stark</mark> Industries"
#       }
#     },
#     [1] {
#       "document"  => {
#         "company_name"  => "Stark Corp",
#         "country"       => "USA",
#         "id"            => "127",
#         "num_employees" => 1031
#       },
#       "highlight" => {
#         "company_name" => "<mark>Stark</mark> Corp"
#       }
#     }
#   ],
#   "page"           => 1,
#   "search_time_ms" => 0
# }

##
# Search for more documents
results = typesense.collections['companies'].documents.search(
  'q' => 'Inc',
  'query_by'  => 'company_name',
  'filter_by' => 'num_employees:<100',
  'sort_by'   => 'num_employees:desc'
)
ap results

# {
#   "facet_counts"   => [],
#   "found"          => 1,
#   "hits"           => [
#     [0] {
#       "document"  => {
#         "company_name"  => "Doofenshmirtz Inc",
#         "country"       => "Tri-State Area",
#         "id"            => "126",
#         "num_employees" => 2
#       },
#       "highlight" => {
#         "company_name" => "Doofenshmirtz <mark>Inc</mark>"
#       }
#     }
#   ],
#   "page"           => 1,
#   "search_time_ms" => 0
# }

##
# Search for more documents
results = typesense.collections['companies'].documents.search(
  'q'        => 'Non-existent',
  'query_by' => 'company_name'
)
ap results

# {
#   "found"          => 0,
#   "hits"           => [],
#   "page"           => 1,
#   "search_time_ms" => 0
# }

##
# Cleanup
# Drop the collection
typesense.collections['companies'].delete
