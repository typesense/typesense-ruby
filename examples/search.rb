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
# Create file in present working directory called typesense-server-peers (update IP Addresses appropriately to your local network):
#   $ echo '172.17.0.2:8107:8108,172.17.0.3:8107:7108,172.17.0.4:8107:9108' > `pwd`/typesense-server-peers
#
# Start node 1:
#   $ docker run -i -p 8108:8108 -p 8107:8107 -v/tmp/typesense-server-data-1b/:/data -v`pwd`/typesense-server-peers:/typesense-server-peers typesense/typesense:0.12.rc8 --data-dir /data --api-key=xyz --search-only-api-key=abcd --listen-port 8108 --peering-port 8107 --enable-cors --nodes=/typesense-server-peers
#
# Start node 2:
#   $ docker run -i -p 7108:7108 -p 7107:7107 -v/tmp/.typesense-server-data-2b/:/data -v`pwd`/typesense-server-peers:/typesense-server-peers typesense/typesense:0.12.rc8 --data-dir /data --api-key=xyz --search-only-api-key=abcd --listen-port 7108 --peering-port 7107 --enable-cors --nodes=/typesense-server-peers
#
# Start node 3:
#   $ docker run -i -p 9108:9108 -p 9107:9107 -v/tmp/.typesense-server-data-3b/:/data -v`pwd`/typesense-server-peers:/typesense-server-peers typesense/typesense:0.12.rc8 --data-dir /data --api-key=xyz --search-only-api-key=abcd --listen-port 9108 --peering-port 9107 --enable-cors --nodes=/typesense-server-peers

##
# Create a client
typesense = Typesense::Client.new(
  nodes: [
    {
      host: 'localhost',
      port: 8108,
      protocol: 'http'
    },
    {
      host: 'localhost',
      port: 7108,
      protocol: 'http'
    },
    {
      host: 'localhost',
      port: 9108,
      protocol: 'http'
    }
  ],
  api_key: 'xyz',
  connection_timeout_seconds: 10,
  logger: Logger.new(STDOUT),
  log_level: Logger::DEBUG
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

# Delete the collection if it already exists
begin
  typesense.collections['companies'].delete
rescue Typesense::Error::ObjectNotFound
end

# Now create the collection
typesense.collections.create(schema)

# Let's create a couple documents for us to use in our search examples
gets
typesense.collections['companies'].documents.create(
  'id' => '124',
  'company_name' => 'Stark Industries',
  'num_employees' => 5215,
  'country' => 'USA'
)

gets
typesense.collections['companies'].documents.create(
  'id' => '127',
  'company_name' => 'Stark Corp',
  'num_employees' => 1031,
  'country' => 'USA'
)

gets
typesense.collections['companies'].documents.create(
  'id' => '125',
  'company_name' => 'Acme Corp',
  'num_employees' => 1002,
  'country' => 'France'
)

gets
typesense.collections['companies'].documents.create(
  'id' => '126',
  'company_name' => 'Doofenshmirtz Inc',
  'num_employees' => 2,
  'country' => 'Tri-State Area'
)

##
# Search for documents
gets
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
gets
results = typesense.collections['companies'].documents.search(
  'q' => 'Inc',
  'query_by' => 'company_name',
  'filter_by' => 'num_employees:<100',
  'sort_by' => 'num_employees:desc'
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
gets
results = typesense.collections['companies'].documents.search(
  'q' => 'Non-existent',
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
gets
typesense.collections['companies'].delete
