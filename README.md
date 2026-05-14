# Typesense Ruby Library [![Gem Version](https://badge.fury.io/rb/typesense.svg)](https://badge.fury.io/rb/typesense) 


Ruby client library for accessing the [Typesense HTTP API](https://github.com/typesense/typesense).

Follows the API spec [here](https://github.com/typesense/typesense-api-spec).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'typesense'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typesense

## Usage

You'll find detailed documentation here: [https://typesense.org/api/](https://typesense.org/api/)

Here are some examples with inline comments that walk you through how to use the Ruby client: [examples](examples)

Tests are also a good place to know how the the library works internally: [spec](spec)

### Error handling

Failed requests raise a subclass of `Typesense::Error`. The exception's `message` is the API error string (`"Object Not Found"`, etc.), and the underlying Faraday response is available on `#data` for callers that need the HTTP status, headers, or raw body:

```ruby
begin
  client.collections['unknown'].retrieve
rescue Typesense::Error::ObjectNotFound => e
  e.message       # => "Not Found"
  e.data.status   # => 404
  e.data.body     # => raw response body
end
```

The exception classes that map to specific status codes are: `RequestMalformed` (400), `RequestUnauthorized` (401), `ObjectNotFound` (404), `ObjectAlreadyExists` (409), `ObjectUnprocessable` (422), `ServerError` (5xx), `HTTPStatus0Error` (status 0), `TimeoutError`, and `HTTPError` (anything else).

### Keep-alive connections

By default, the client opens a fresh HTTP connection (and TLS handshake) for every request. For high-traffic applications this can dominate request latency. Setting `keep_alive_connections: true` enables persistent connections via the `:net_http_persistent` Faraday adapter:

```ruby
Typesense::Client.new(
  api_key: ENV['TYPESENSE_API_KEY'],
  nodes: [{ host: 'localhost', port: 8108, protocol: 'https' }],
  connection_timeout_seconds: 3,
  num_retries: 1,
  keep_alive_connections: true
)
```

Notes:

- Connections are cached per `(thread, node)`. `Net::HTTP` is not thread-safe, so each thread maintains its own keep-alive socket to each Typesense node, and the existing node round-robin still works.
- A cached connection is dropped automatically when a network error occurs, so retries open a fresh socket. We recommend setting `num_retries` to at least `1` so the gem can recover from a server- or load-balancer-side idle timeout transparently.
- Idle sockets are closed after 30 seconds by default. Override with `keep_alive_idle_timeout_seconds` to match or stay under your load balancer's idle timeout.
- The underlying `net_http_persistent` adapter holds at most `keep_alive_pool_size` sockets per origin (default `1`, which matches the per-`(thread, node)` cache above). The default of `1` is the safe choice for the vast majority of users — because we already cache one Faraday connection per `(thread, node)` and `Net::HTTP` is not thread-safe, a single socket per pool is all the adapter needs. Only raise this if you have a specific reason to keep additional sockets warm per origin (e.g. a non-standard concurrency model layered on top of this client); a larger pool will not increase request throughput on its own.
- `keep_alive_idle_timeout_seconds` and `keep_alive_pool_size` are only valid when `keep_alive_connections: true`; setting them otherwise raises `Typesense::Error::MissingConfiguration`.
- The option defaults to `false`, so upgrading the gem does not change behaviour until you opt in.

## Compatibility

| Typesense Server | typesense-ruby |
|------------------|----------------|
| \>= v30.0        | \>= v5.0.0     |
| \>= v28.0        | \>= v3.0.0     |
| \>= v0.25.0      | \>= v1.0.0     |
| \>= v0.23.0      | \>= v0.14.0    |
| \>= v0.21.0      | \>= v0.13.0    |
| \>= v0.20.0      | \>= v0.12.0    |
| \>= v0.19.0      | \>= v0.11.0    |
| \>= v0.18.0      | \>= v0.10.0    |
| \>= v0.17.0      | \>= v0.9.0     |
| \>= v0.16.0      | \>= v0.8.0     |
| \>= v0.15.0      | \>= v0.7.0     |
| \>= v0.12.1      | \>= v0.5.0     |
| \>= v0.12.0      | \>= v0.4.0     |
| <= v0.11         | <= v0.3.0      |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

### Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [typesense/typesense-ruby](https://github.com/typesense/typesense-ruby).
