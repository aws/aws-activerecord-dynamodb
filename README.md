# Aws::Record generators for Rails

[![Gem Version](https://badge.fury.io/rb/aws-record-rails.svg)](https://badge.fury.io/rb/aws-record-rails)
[![Build Status](https://github.com/aws/aws-record-rails/workflows/CI/badge.svg)](https://github.com/aws/aws-record-rails/actions)
[![Github forks](https://img.shields.io/github/forks/aws/aws-record-rails.svg)](https://github.com/aws/aws-record-rails/network)
[![Github stars](https://img.shields.io/github/stars/aws/aws-record-rails.svg)](https://github.com/aws/aws-record-rails/stargazers)

This gem contains Rails
[scaffolding generators](https://guides.rubyonrails.org/getting_started.html#mvc-and-you)
for models and controllers using
[Aws::Record](https://docs.aws.amazon.com/sdk-for-ruby/aws-record/api/Aws/Record.html).

## Installation

Add this gem to your Rails project's Gemfile:

```ruby
gem 'aws-sdk-rails', '~> 5'
gem 'aws-record-rails', '~> 0'
```

Then run `bundle install`.

This gem also brings in the following AWS gems:

* `aws-record` -> `aws-sdk-dynamodb`

You will have to ensure that you provide credentials for the SDK to use. See the
latest [AWS SDK for Ruby Docs](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html#Configuration)
for details.

If you're running your Rails application on Amazon EC2, the AWS SDK will
check Amazon EC2 instance metadata for credentials to load. Learn more:
[IAM Roles for Amazon EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

## Usage

Invoke the generator by calling `rails generate aws_record:model ...`

If DynamoDB will be the only datastore you plan on using, you can also set
`aws_record` to be your project's default orm with:

```ruby
config.generators do |g|
  g.orm :aws_record
end
```

Which will cause `aws_record:model` to be invoked with `rails generate model ...`

### Generating a model

Generating a model can be as simple as:

    rails generate aws_record:model Forum --table-config primary:10-5

The generator will automatically create a `uuid:hash_key` field for you, and
a table config with the provided r/w units:

```ruby
# app/models/forum.rb

require 'aws-record'

class Forum
  include Aws::Record

  string_attr :uuid, hash_key: true
end

# db/table_config/forum_config.rb

require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class Forum

      t.read_capacity_units 10
      t.write_capacity_units 5
    end
  end
end
```

More complex models can be created by adding more fields to the model as well as other options:

    rails generate aws_record Forum post_id:rkey author_username post_title post_body tags:sset:default_value{Set.new}

```ruby
# app/models/forum.rb

require 'aws-record'

class Forum
  include Aws::Record

  string_attr :uuid, hash_key: true
  string_attr :post_id, range_key: true
  string_attr :author_username
  string_attr :post_title
  string_attr :post_body
  string_set_attr :tags, default_value: Set.new
end

# db/table_config/forum_config.rb
# ...
```

Finally you can attach a variety of options to your fields, and even
`ActiveModel` validations to the models:

    rails generate aws_record:model Forum forum_uuid:hkey post_id:rkey author_username post_title post_body tags:sset:default_value{Set.new} created_at:datetime:db_attr_name{PostCreatedAtTime} moderation:boolean:default_value{false} --table-config=primary:5-2 AuthorIndex:12-14 --required=post_title --length-validations=post_body:50-1000 --gsi=AuthorIndex:hkey{author_username}`

```ruby

# app/models/forum.rb

require 'aws-record'
require 'active_model'

class Forum
  include Aws::Record
  include ActiveModel::Validations

  string_attr :forum_uuid, hash_key: true
  string_attr :post_id, range_key: true
  string_attr :author_username
  string_attr :post_title
  string_attr :post_body
  string_set_attr :tags, default_value: Set.new
  datetime_attr :created_at, database_attribute_name: "PostCreatedAtTime"
  boolean_attr :moderation, default_value: false

  global_secondary_index(
    :AuthorIndex,
    hash_key: :author_username,
    projection: {
      projection_type: "ALL"
    }
  )
  validates_presence_of :post_title
  validates_length_of :post_body, within: 50..1000
end

# db/table_config/forum_config.rb
# ...

```

To migrate your new models and begin using them you can run the provided rake task:

    bundle exec rails aws_record:migrate

### Scaffolding

If you invoke `aws_record:scaffold` instead of `aws_record:model` then the
generator will construct a full controller-view-model structure. 

### Docs

The syntax for creating an aws-record model follows:

`rails generate aws_record:model NAME [field[:type][:opts]...] [options]`

The possible field types are:

```markdown
| Field Name                       | aws-record attribute type |
|----------------------------------|---------------------------|
| bool | boolean                   | :boolean_attr             |
| date                             | :date_attr                |
| datetime                         | :datetime_attr            |
| float                            | :float_attr               |
| int | integer                    | :integer_attr             |
| list                             | :list_attr                |
| map                              | :map_attr                 |
| num_set | numeric_set | nset     | :numeric_set_attr         |
| string_set | s_set | sset        | :string_set_attr          |
| string                           | :string_attr              |
```

If a type is not provided the generator will assume the field is of type `:string_attr`

Additionally a number of options may be attached as a comma seperated list to the field:

```markdown
| Field Option Name                         | aws-record option                                                                   |
|-------------------------------------------|-------------------------------------------------------------------------------------|
| hkey                                      | marks an attribute as a hash_key                                                    |
| rkey                                      | marks an attribute as a range_key                                                   |
| persist_nil                               | will persist nil values in a attribute                                              |
| db_attr_name{NAME}                        | sets a secondary name for an attribute, these must be unique across attribute names |
| ddb_type{S|N|B|BOOL|SS|NS|BS|M|L}         | sets the dynamo_db_type for an attribute                                            |
| default_value{Object}                     | sets the default value for an attribute                                             |
```

Additional options:

```markdown
| Command Option Names                                                                   | Purpose                                                                                                                            |
|----------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| [--skip-namespace], [--no-skip-namespace]                                              | Skip namespace (affects only isolated applications)                                                                                |
| [--disable-mutation-tracking], [--no-disable-mutation-tracking]                        | Disables dirty tracking                                                                                                            |
| [--timestamps], [--no-timestamps]                                                      | Adds created, updated timestamps to the model                                                                                      |
| --table-config=primary:R-W [SecondaryIndex1:R-W]...                                    | Declares the r/w units for the model as well as any secondary indexes                                                          |
| [--gsi=name:hkey{field_name}[,rkey{field_name},proj_type{ALL|KEYS_ONLY|INCLUDE}]...]   | Allows for the declaration of secondary indexes                                                                                    |
| [--required=field1 ...]                                                                | A list of attributes that are required for an instance of the model                                                               |
| [--length-validations=field1:MIN-MAX...]                                               | Validations on the length of attributes in a model                                                                                 |
| [--table-name=name]                                                                    | Sets the name of the table in DynamoDB, if different than the model name                                                        |
| [--skip-table-config]                                                                  | Doesn't generate a table config for the model                                                                                      |
| [--password-digest]                                                                    | Adds a password field (note that you must have bcrypt has a dependency) that automatically hashes and manages the model password |
| [--scaffold]                                                                           | Adds helpers methods that are used by the scaffolding                                                                              |
```

The included rake task `aws_record:migrate` will run all of the migrations in `app/db/table_config`
