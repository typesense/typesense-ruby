# Typesense Ruby Library [![Gem Version](https://badge.fury.io/rb/typesense.svg)](https://badge.fury.io/rb/typesense) [![CircleCI](https://circleci.com/gh/typesense/typesense-ruby.svg?style=shield&circle-token=063f2179925b0b37d540126f6c96f6e1fe23f1b9)](https://circleci.com/gh/typesense/typesense-ruby)


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

Here are some examples that show you how the Ruby client works: [examples](examples)

Tests are also a good place to know how the the library works internally: [spec](spec)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [typesense/typesense-ruby](https://github.com/typesense/typesense-ruby).