require "test_helper"

CustomUser = Struct.new(:id, :name, :email) do
  def greet
    "Hi, my name is #{name}."
  end
end

TopGunUser = Struct.new(:call_sign) do
  def greet
    "Hello, my call sign is #{call_sign}."
  end
end

class TestPluckToStruct < Minitest::Test
  def setup
    PluckToStruct.clear_struct_cache!
    User.delete_all
    Post.delete_all

    @user1 = User.create!(name: "Alice", email: "alice@example.com", age: 25)
    @user2 = User.create!(name: "Bob", email: "bob@example.com", age: 30)
    @user3 = User.create!(name: "Charlie", email: "charlie@example.com", age: 35)

    @post1 = Post.create!(title: "Post 1", content: "Content 1", user: @user1, published: true)
    @post2 = Post.create!(title: "Post 2", content: "Content 2", user: @user2, published: false)
    @post3 = Post.create!(title: "Post 3", content: "Content 3", user: @user2, published: true)
  end

  test "struct class have meaningful names" do
    user = User.pluck_to_struct(:name, :email).first

    assert user.class.name.include? "User_PluckToStruct_email_name"
  end

  test "plucking a single column" do
    alice = User.pluck_to_struct(:name).first

    assert alice.is_a?(Struct)
    assert_equal @user1.name, alice.name
  end

  test "plucking multiple columns" do
    alice = User.pluck_to_struct(:name, :email).first

    assert alice.is_a?(Struct)
    assert_equal @user1.name, alice.name
    assert_equal @user1.email, alice.email
  end

  test "plucking strings" do
    alice = User.pluck_to_struct("name", "email").first

    assert alice.is_a?(Struct)
    assert_equal @user1.name, alice.name
    assert_equal @user1.email, alice.email
  end

  test "plucking symbols and strings" do
    alice = User.pluck_to_struct(:name, "email", :age).first

    assert alice.is_a?(Struct)
    assert_equal @user1.name, alice.name
    assert_equal @user1.email, alice.email
    assert_equal @user1.age, alice.age
  end

  test "no arguments plucks all columns" do
    alice = User.pluck_to_struct.first

    assert alice.is_a?(Struct)
    assert_respond_to alice, :id
    assert_respond_to alice, :name
    assert_respond_to alice, :email
    assert_respond_to alice, :age
    assert_respond_to alice, :created_at
    assert_respond_to alice, :updated_at
  end

  test "empty result set returns empty array" do
    results = User.where(name: "NonExistent").pluck_to_struct(:name, :email)

    assert_equal [], results
    assert_equal 0, results.length
  end

  test "plucking with conditions" do
    results = User.where(age: @user1.age..@user2.age).pluck_to_struct(:name, :age)

    assert_equal 2, results.length
    names = results.map(&:name)
    assert_equal %w[Alice Bob], names
  end

  test "plucking with joins works" do
    results = User.joins(:posts).where(posts: { published: false }).pluck_to_struct(:name, :email)

    bob = results.first
    assert bob.is_a?(Struct)
    assert_equal "Bob", bob.name
    assert_equal "bob@example.com", bob.email
  end

  test "plucking with group and count" do
    results = Post.joins(:user)
                  .where(published: true)
                  .group("users.name")
                  .pluck_to_struct("users.name AS author", "COUNT(*) AS post_count")

    assert_equal 2, results.length

    alice = results.first
    assert alice.is_a?(Struct)
    assert_equal @user1.name, alice.author
    assert_equal 1, alice.post_count
  end

  test "plucking with order and limit" do
    results = User.order(:age).limit(2).pluck_to_struct(:name, :age)

    assert_equal 2, results.length
    assert_equal @user1.name, results.first.name
    assert_equal @user1.age, results.first.age
    assert_equal "Bob", results.last.name
    assert_equal @user2.age, results.last.age
  end

  test "plucking with a custom struct class" do
    alice = User.pluck_to_struct(:id, :name, :email, klass_name: "CustomUser").first

    assert_instance_of CustomUser, alice
    assert_equal @user1.name, alice.name
    assert_equal @user1.email, alice.email
    assert_equal "Hi, my name is Alice.", alice.greet
  end

  test "plucking with a custom struct class and aliased attributes" do
    alice = User.pluck_to_struct("name AS call_sign", klass_name: "TopGunUser").first

    assert_instance_of TopGunUser, alice
    assert_equal @user1.name, alice.call_sign
    assert_equal "Hello, my call sign is Alice.", alice.greet
  end

  test "plucking with associations" do
    post = Post.joins(:user).pluck_to_struct("posts.id", "posts.title", "users.name AS author").first

    assert post.is_a?(Struct)
    assert_equal @post1.id, post.id
    assert_equal @post1.title, post.title
    assert_equal @user1.name, post.author
  end

  test "plucking invalid column name raises error" do
    assert_raises(ActiveRecord::StatementInvalid) do
      User.limit(1).pluck_to_struct("invalid_column_name")
    end
  end

  test "plucking with non-existent struct class raises error" do
    assert_raises(NameError) do
      User.pluck_to_struct(:name, :email, klass_name: "NonExistentStruct")
    end
  end

  test "plucking with SQL injection protection" do
    malicious_input = "name; DROP TABLE users; --"

    assert_raises(ActiveRecord::StatementInvalid) do
      User.pluck_to_struct(malicious_input)
    end
  end

  test "plucking with nil values" do
    no_name = User.create!(name: nil, email: "test@example.com", age: @user1.age)
    results = User.where(name: nil).pluck_to_struct(:name, :email)

    assert_equal 1, results.length
    result = results.first
    assert_nil result.name
    assert_equal no_name.email, result.email
  end

  def test_boolean_values_preserved
    results = Post.pluck_to_struct(:title, :published)
    published_post = results.find { |p| p.published == true }
    unpublished_post = results.find { |p| p.published == false }

    refute_nil published_post
    refute_nil unpublished_post
    assert_equal true, published_post.published
    assert_equal false, unpublished_post.published
  end

  test "integer values preserved" do
    results = User.pluck_to_struct(:age)

    assert_equal 3, results.length

    results.each do |result|
      assert result.age.is_a?(Integer)
      assert result.age > 0
    end
  end

  test "datetime values preserved" do
    results = User.pluck_to_struct(:created_at, :updated_at)

    assert_equal 3, results.length

    results.each do |result|
      assert result.created_at.is_a?(Time)
      assert result.updated_at.is_a?(Time)
    end
  end

  test "struct classes are cached and reused" do
    results1 = User.pluck_to_struct(:name, :email)
    struct_class1 = results1.first.class

    results2 = User.pluck_to_struct(:name, :email)
    struct_class2 = results2.first.class

    assert_same struct_class1, struct_class2, "Same Struct class should be reused for identical attribute sets"

    # Different attributes should create a different class
    results3 = User.pluck_to_struct(:name, :age)
    struct_class3 = results3.first.class

    refute_same struct_class1, struct_class3, "Different attribute sets should create different Struct classes"
  end

  test "struct class cache is thread-safe" do
    threads = []
    model_name = "User"
    attribute_names = [ :name, :email ]

    10.times do
      threads << Thread.new do
        PluckToStruct.get_or_create_struct_class(model_name, attribute_names)
      end
    end

    threads.each(&:join)

    # All threads should have received the same Struct class
    struct_classes = PluckToStruct.struct_cache.keys
    assert_equal 1, struct_classes.length, "All threads should receive the same cached Struct class"
  end

  test "struct classes for different models are unique" do
    user_results = User.pluck_to_struct(:name, :email)
    post_results = Post.pluck_to_struct(:title)

    user_struct_class = user_results.first.class
    post_struct_class = post_results.first.class

    refute_same user_struct_class, post_struct_class, "Different models should have different Struct classes"
  end

  test "clearing struct cache removes all entries" do
    User.pluck_to_struct(:name, :email)

    cache_size = PluckToStruct.struct_cache.size
    assert_equal 1, cache_size

    PluckToStruct.clear_struct_cache!

    assert_equal 0, PluckToStruct.struct_cache.size
  end

  test "universal Arel.sql wrapping works for SQL expressions" do
    expressions_to_test = [
      "COUNT(*) AS total",
      "SUM(age) AS total_age",
      "AVG(age) AS average_age",
      "name || ' ' || email AS full_info",
      "CASE WHEN age > 30 THEN 'senior' ELSE 'junior' END AS category",
      "DISTINCT name",
      "age * 2 AS double_age",
      "updated_at - created_at AS duration",
      "CONCAT(name, ' ', email) AS full_info",
      "CAST(created_at AS DATE) AS creation_date",
      "UPPER(name) AS uppercase_name",
      "COALESCE(name, email) AS display_name"
    ]

    expressions_to_test.each do |expr|
      User.limit(1).pluck_to_struct(expr)
    end
  end
end
