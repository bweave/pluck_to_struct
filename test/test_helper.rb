$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "pluck_to_struct"
require "minitest/autorun"
require "minitest/focus"
require "minitest/pride"
require "active_record"
require "sqlite3"
require "benchmark"
require "debug"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.string :email
    t.integer :age
    t.timestamps
  end

  create_table :posts do |t|
    t.string :title
    t.text :content
    t.integer :user_id
    t.boolean :published, default: false
    t.timestamps
  end
end

class User < ActiveRecord::Base
  include PluckToStruct
  has_many :posts
end

class Post < ActiveRecord::Base
  include PluckToStruct
  belongs_to :user
end

class Minitest::Test
  # Helper to define a test method using a String. Under the hood, it replaces
  # spaces with underscores and defines the test method.
  #
  #   test "verify something" do
  #     ...
  #   end
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/, '_')}".to_sym
    defined = method_defined? test_name
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end
end
