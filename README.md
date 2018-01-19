# Typesense Ruby Gem

Ruby client library for accessing the [Typesense HTTP API](https://github.com/wreally/typesense).

Follows the API spec [here](https://github.com/wreally/typesense-api-spec).

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

#### Configure

Configure the gem (in an initializer if you're using Rails):

```ruby
Typesense.configure do |config|
  config.host = 'localhost:8108'
  config.protocol = 'http'
  config.api_key = 'abcd'
end
```

#### Create a collection

```ruby
schema = {
        'name'                => 'companies',
        'fields'              => [
            {
                'name'  => 'company_name',
                'type'  => 'string',
                'facet' => false
            },
            {
                'name'  => 'num_employees',
                'type'  => 'int32',
                'facet' => false
            },
            {
                'name'  => 'country',
                'type'  => 'string',
                'facet' => true
            }
        ],
        'token_ranking_field' => 'num_employees'
    }
    
result = Typesense::Collections.create(schema)
```


#### Retrieve a collection

```ruby    
Typesense::Collections.retrieve('companies')
```
```ruby
{
    'name'                => 'companies',
    'num_documents'       => 0,
    'fields'              => [
        {
            'name'  => 'company_name',
            'type'  => 'string',
            'facet' => false
        },
        {
            'name'  => 'num_employees',
            'type'  => 'int32',
            'facet' => false
        },
        {
            'name'  => 'country',
            'type'  => 'string',
            'facet' => true
        }
    ],
    'token_ranking_field' => 'num_employees'
}

```

#### Work in progress...

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/wreally/typesense-ruby].

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
