# frozen_string_literal: true

require_relative '../lib/typesense'
require 'awesome_print'

AwesomePrint.defaults = {
  indent: -2
}

##
## Setup
#
### Option 1: Start a single-node cluster
#     $ docker run -i -p 8108:8108 -v/tmp/typesense-server-data-1b/:/data -v`pwd`/typesense-server-peers:/typesense-server-peers typesense/typesense:0.12.rc9 --data-dir /data --api-key=xyz --search-only-api-key=abcd --listen-port 8108 --enable-cors
#
### Option 2: Start a 3-node cluster
#
# Create file in present working directory called typesense-server-peers (update IP Addresses appropriately to your local network):
#   $ echo '172.17.0.2:8107:8108,172.17.0.3:7107:7108,172.17.0.4:9107:9108' > `pwd`/typesense-server-peers
#
# Start node 1:
#   $ docker run -i -p 8108:8108 -p 8107:8107 -v/tmp/typesense-server-data-1b/:/data -v`pwd`/typesense-server-peers:/typesense-server-peers typesense/typesense:0.12.rc9 --data-dir /data --api-key=xyz --search-only-api-key=abcd --listen-port 8108 --peering-port 8107 --enable-cors --nodes=/typesense-server-peers
#
# Start node 2:
#   $ docker run -i -p 7108:7108 -p 7107:7107 -v/tmp/.typesense-server-data-2b/:/data -v`pwd`/typesense-server-peers:/typesense-server-peers typesense/typesense:0.12.rc9 --data-dir /data --api-key=xyz --search-only-api-key=abcd --listen-port 7108 --peering-port 7107 --enable-cors --nodes=/typesense-server-peers
#
# Start node 3:
#   $ docker run -i -p 9108:9108 -p 9107:9107 -v/tmp/.typesense-server-data-3b/:/data -v`pwd`/typesense-server-peers:/typesense-server-peers typesense/typesense:0.12.rc9 --data-dir /data --api-key=xyz --search-only-api-key=abcd --listen-port 9108 --peering-port 9107 --enable-cors --nodes=/typesense-server-peers
#
# Note: Be sure to add `--license-key=<>` at the end when starting a Typesense Premium server

##
# Create a client
@typesense = Typesense::Client.new(
  nodes: [
    {
      host: 'localhost',
      port: 8108,
      protocol: 'http'
    },
    # Uncomment if starting a 3-node cluster, using Option 2 under Setup instructions above
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
  # If this optional key is specified, requests are always sent to this node first if it is healthy
  #   before falling back on the nodes mentioned in the `nodes` key. This is useful when running a distributed set of search clusters.
  'distributed_search_node': {
    'host': 'localhost',
    'port': '8108',
    'protocol': 'http'
  },
  api_key: 'xyz',
  num_retries: 10,
  healthcheck_interval_seconds: 1,
  retry_interval_seconds: 0.01,
  connection_timeout_seconds: 10,
  logger: Logger.new(STDOUT),
  log_level: Logger::DEBUG
)
