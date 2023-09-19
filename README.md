# PluckToStruct

`PluckToStruct` is an `include`-able concern for your Rails models that allows you to hydrate lightweight `Struct`s in place of `ActiveRecord`'s heavyweight models. It's ideal for use in scenarios where performance is crucial. It can also provide you a path toward relegating `ActiveRecord` to database-only use, where your custom `Struct`s take the place of typical Rails model instances in views, etc.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

First, include `PluckToStruct` in your Rails model:

```
class Post < ApplicationRecord
  include PluckToStruct
end
```
The method signature looks like this:

```
Post.pluck_to_struct(*selects, custom_klass_name: "MyPost")
```

The `selects` arg works just like `ActiveRecord`'s [.pluck](https://guides.rubyonrails.org/active_record_querying.html#pluck). And the `custom_klass_name` kwarg allows you to specify a class name for the returned `Struct`, or pass in the name of a predefined one. More on this below.

### Examples

1. By default, with no `selects` args passed, it will `pluck` all columns on the model, and dynamically generate a Struct for you.

```
posts = Post.pluck_to_stuct
#=> [<Post::Plucked_id_title_body_created_at_updated_at id=1 title="Title" body="A great post!"...>]
```
2. You can pass in the `selects` you want.

```
posts = Post.pluck_to_stuct(:id, :title)
#=> [<Post::Plucked_id_title id=1 title="Title">]
```

3. You can provide a custom name for the returned Struct.

```
posts = Post.pluck_to_stuct(:id, :title, custom_klass_name: "MyPost")
#=> [<Post::MyPost id=1 title="Title">]
```

4. You can define your own Struct ahead of time, and use it.

```
MyPost = Struct.new(:id, :title, :body) do
  def summary
    "This is the contrived summary."
  end
end

posts = Post.pluck_to_stuct(:id, :title, :body, custom_klass_name: MyPost.name)
#=> [<MyPost id=1 title="Title" body="A great post!">]

posts.first.summary
#=> "This is the contrived summary."
```

5. `selects` args with table names and aliases are supported.

```
posts = Post.pluck_to_stuct(:id, "posts.title", "body as content")
#=> [<Post::Plucked_id_title_content id=1 title="Title" content="A great post!">]
```

6. You can also use `.pluck_to_struct` across related models.

```
class Author < ApplicationRecord
  include PluckToStruct

  has_many :posts
end

class Post < ApplicationRecord
  include PluckToStruct

  belongs_to :author
  has_many :comments
end

class Comment < ApplicationRecord
  include PluckToStruct

  belongs_to :post
end

PostWithAuthorAndComments = Struct.new(:id, :title, :author, :grouped_comments) do
  def comments
    grouped_comments.split(",")
  end
end

posts = Post.includes(:author, :comments)
            .group("posts.id")
            .pluck_to_struct(
              "posts.id",
              "posts.title",
              "authors.name AS author",
              Arel.sql("GROUP_CONCAT(comments.body) AS grouped_comments"),
              custom_klass_name: PostWithComments.name
            )

#=> [<PostWithAuthorAndComments id=1 title="Title"...>]

posts.first.author
#=> "Ernest Hemingway"

posts.first.comments
#=> ["What a great post!", "This is total junk!", "Never read the comments!"]
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bweave/pluck_to_struct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
