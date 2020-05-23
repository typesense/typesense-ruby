# frozen_string_literal: true

##
# These examples walk you through operations specifically related to aliases
# # This is a Typesense Premium feature (see: https://typesense.org/premium)
# Be sure to add `--license-key=<>` as a parameter, when starting a Typesense Premium server

require_relative './client_initialization'

# Create a collection
create_response = @typesense.collections.create(
  "name": 'books_january',
  "fields": [
    { "name": 'title', "type": 'string' },
    { "name": 'authors', "type": 'string[]' },
    { "name": 'authors_facet', "type": 'string[]', "facet": true },
    { "name": 'publication_year', "type": 'int32' },
    { "name": 'publication_year_facet', "type": 'string', "facet": true },
    { "name": 'ratings_count', "type": 'int32' },
    { "name": 'average_rating', "type": 'float' },
    { "name": 'image_url', "type": 'string' }
  ],
  "default_sorting_field": 'ratings_count'
)

ap create_response

# Create or update an existing alias
create_alias_response = @typesense.aliases.upsert('books',
                                                  "collection_name": 'books_january')
ap create_alias_response

# Add a book using the alias name `books`
hunger_games_book = {
  'id': '1', 'original_publication_year': 2008, 'authors': ['Suzanne Collins'], 'average_rating': 4.34,
  'publication_year': 2008, 'publication_year_facet': '2008', 'authors_facet': ['Suzanne Collins'],
  'title': 'The Hunger Games',
  'image_url': 'https://images.gr-assets.com/books/1447303603m/2767052.jpg',
  'ratings_count': 4_780_653
}

@typesense.collections['books'].documents.create(hunger_games_book)

# Search using the alias
ap @typesense.collections['books'].documents.search(
  'q': 'hunger',
  'query_by': 'title',
  'sort_by': 'ratings_count:desc'
)

# List all aliases
ap @typesense.aliases.retrieve

# Retrieve the configuration of a specific alias
ap @typesense.aliases['books'].retrieve

# Delete an alias
ap @typesense.aliases['books'].delete
