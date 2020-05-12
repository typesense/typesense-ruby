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

##
# Retrieve a document
document = @typesense.collections['companies'].documents['124'].retrieve
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
ap @typesense.collections['companies'].documents.create_many(documents)

##
# Export all documents in a collection in JSON Lines format
#   We use JSON Lines format for performance reasons. You can choose to parse selected lines (elements in the array) as needed.
array_of_json_strings = @typesense.collections['companies'].documents.export
ap array_of_json_strings

# [
# [0] "{\"company_name\":\"Stark Industries\",\"country\":\"USA\",\"id\":\"124\",\"num_employees\":5215}",
# [1] "{\"company_name\":\"Acme Corp\",\"country\":\"France\",\"id\":\"125\",\"num_employees\":1002}"
# ]

##
# Cleanup
# Drop the collection
@typesense.collections['companies'].delete
