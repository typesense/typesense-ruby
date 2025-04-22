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

## Compatibility

| Typesense Server | typesense-ruby |
|------------------|----------------|
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
