# frozen_string_literal: true

def setup_database
  establish_connection
  reset_database
  migrate_database
  seed_database
end

def establish_connection
  ActiveRecord::Base.establish_connection(
    adapter: "sqlite3",
    dbfile: ":memory:",
    database: "tmp/test_pluck_to_struct"
  )

  # Uncomment the next line for query logging when running tests
  # ActiveRecord::Base.logger = Logger.new($stderr)
end

def reset_database
  ActiveRecord::Base.connection.drop_table :comments
  ActiveRecord::Base.connection.drop_table :posts
  ActiveRecord::Base.connection.drop_table :authors
rescue StandardError
  nil
end

def migrate_database # rubocop:disable Metrics/MethodLength
  ActiveRecord::Schema.define do
    create_table :authors do |t|
      t.column :name, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :posts do |t|
      t.references :author, null: false, index: true
      t.column :title, :string
      t.column :body, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :comments do |t|
      t.references :post, null: false, index: true
      t.column :body, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end
end

def seed_database # rubocop:disable Metrics/MethodLength
  author = Author.create!(name: "Herbert Meninger")

  3.times do |i|
    author
      .posts
      .create!(title: "Title #{i}", body: "This is post #{i}'s body.")
      .tap do |post|
        3.times do |j|
          post.comments.create!(body: "This is comment #{j} for post #{i}.")
        end
      end
  end
end
