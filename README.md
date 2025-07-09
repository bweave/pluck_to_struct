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
end

# Then, you can use the `pluck_to_struct` method to retrieve data as Structs:
users = User.pluck_to_struct(:id, :name, :email)

# Specify a custom Struct class if needed:
Pilot = Struct.new(:id, :callsign, :email)
pilots = User.pluck_to_struct(:id, :name, :email, struct_class: Pilot)

# You can also pass a block:
users = User.pluck_to_struct(:id, :name, :email) do |user|
  user.email = user.email.upcase
  user
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/bweave/pluck_to_struct>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
