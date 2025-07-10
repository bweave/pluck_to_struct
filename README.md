# PluckToStruct

PluckToStruct is an include-able concern for your Rails models that allows you to hydrate lightweight Structs in place of ActiveRecord's heavyweight models. It's ideal for use in scenarios where performance is crucial. It can also provide you a path toward relegating ActiveRecord to database-only use, where your custom Structs take the place of typical Rails model instances in views, etc.

## Installation

Add it to your Gemfile:

```
gem 'pluck_to_struct'
```

## Usage

In your Rails model, include the `PluckToStruct` concern:

```ruby
class User < ApplicationRecord
  include PluckToStruct
  has_many :posts
end

class Post < ApplicationRecord
  include PluckToStruct
  belongs_to :user
end
```

Then, you can use the `pluck_to_struct` method to retrieve data as Structs:

```ruby
users = User.pluck_to_struct(:id, :name, :email)
users.first #=> #<struct Struct::User_PluckToStruct_email_id_name id=1, name="Alice Johnson", email="alice@example.com">

# Strings, Symbols, and SQL fragments are all supported:
users = User.pluck_to_struct("id", "name", "email")
users = User.pluck_to_struct(:id, :name, "email AS email_address")
users = User.joins(:posts).pluck_to_struct(:id, :name, "COUNT(*) AS posts_count")
```

Specify a custom Struct class for more control and flexibility:

```ruby
Pilot = Struct.new(:id, :callsign, :email)
pilots = User.pluck_to_struct(:id, :name, :email, klass_name: Pilot)
pilots.first #=> #<struct Pilot id=1, callsign="Alice Johnson", email="alice@example.com">
```

You can also pass a block:

```ruby
users = User.pluck_to_struct(:id, :name, :email) do |user|
  user.email = user.email.upcase
  user
end
users.first #=> #<struct Struct::User_PluckToStruct_email_id_name id=1, name="Alice Johnson", email="ALICE@EXAMPLE.COM">
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/bweave/pluck_to_struct>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
