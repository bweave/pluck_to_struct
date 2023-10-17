# frozen_string_literal: true

require "test_helper"

class PluckToStructTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  test "it has a version" do
    refute_nil ::PluckToStruct::VERSION
  end

  test ".pluck_to_struct returns lightweight Structs" do
    Post.pluck_to_struct.all? { |post| assert_kind_of(Struct, post) }
  end

  test ".pluck_to_struct the boring happy path defaults for Struct name and plucked columns" do
    post = Post.pluck_to_struct.first
    expected = Post.column_names
    expected.each { |msg| assert_respond_to(post, msg) }
  end

  test ".pluck_to_struct generates a unique name" do
    expected = "Post::Plucked_id_author_id_title_body_created_at_updated_at"
    post = Post.pluck_to_struct.first

    assert_equal expected, post.class.name
  end

  test ".pluck_to_struct custom Struct name that doesn't already exist" do
    post = Post.pluck_to_struct(custom_klass_name: "Custom").first
    expected = "Post::Custom"
    assert_equal expected, post.class.name
  end

  test ".pluck_to_struct using a predefined Struct" do
    post = Post.pluck_to_struct(custom_klass_name: LightweightPost.name).first
    assert_equal "LightweightPost", post.class.name.demodulize
  end

  test ".pluck_to_struct single custom column" do
    post = Post.pluck_to_struct("title").first
    assert_respond_to post, :title

    post = Post.pluck_to_struct(:title).first
    assert_respond_to post, :title
  end

  test ".pluck_to_struct table-namespaced custom columns" do
    post = Post.pluck_to_struct("posts.id", "posts.title").first
    assert_respond_to post, :id
    assert_respond_to post, :title
  end

  test ".pluck_to_struct aliased columns" do
    post = Post.pluck_to_struct("title as name").first
    assert_respond_to post, :name

    post = Post.pluck_to_struct("posts.title as name").first
    assert_respond_to post, :name

    post =
      Post
        .includes(:comments)
        .pluck_to_struct("id", "title", "comments.body as comments")
        .first
    assert_respond_to post, :id
    assert_respond_to post, :title
    assert_respond_to post, :comments
  end

  test ".pluck_to_struct plucking specific columns across relationships" do
    post_with_comments =
      Struct.new("PostWithComments", :id, :title, :author, :grouped_comments) do
        def comments
          grouped_comments.split(",")
        end
      end
    post =
      Post
        .includes(:author, :comments)
        .group("posts.id")
        .pluck_to_struct(
          "posts.id",
          "posts.title",
          "authors.name AS author",
          Arel.sql("GROUP_CONCAT(comments.body) AS grouped_comments"),
          custom_klass_name: post_with_comments.name
        )
        .first

    assert_respond_to post, :id
    assert_respond_to post, :title
    assert_respond_to post, :comments
    assert_respond_to post, :author
  end

  test ".pluck_to_hash returns a hash" do
    Post.pluck_to_hash.all? { |post| assert_kind_of(Hash, post) }
  end

  test ".pluck_to_hash has the expected keys" do
    post = Post.pluck_to_hash.first
    expected = Post.column_names.map(&:to_sym)
    assert_equal expected, post.keys
  end

  test ".pluck_to_hash single custom column" do
    post = Post.pluck_to_hash("title").first
    assert_equal %i[title], post.keys

    post = Post.pluck_to_hash(:title).first
    assert_equal %i[title], post.keys
  end

  test ".pluck_to_hash table-namespaced custom columns" do
    post = Post.pluck_to_hash("posts.id", "posts.title").first
    assert_equal %i[id title], post.keys
  end

  test ".pluck_to_hash aliased columns" do
    post = Post.pluck_to_hash("title as name").first
    assert_equal %i[name], post.keys

    post = Post.pluck_to_hash("posts.title as name").first
    assert_equal %i[name], post.keys

    post =
      Post
        .includes(:comments)
        .pluck_to_hash("id", "title", "comments.body as comments")
        .first
    assert_equal %i[id title comments], post.keys
  end

  test ".pluck_to_hash plucking specific columns across relationships" do
    post =
      Post
        .includes(:author, :comments)
        .group("posts.id")
        .pluck_to_hash(
          "posts.id",
          "posts.title",
          "authors.name AS author",
          Arel.sql("GROUP_CONCAT(comments.body) AS comments")
        )
        .first

    assert_equal %i[id title author comments], post.keys
  end
end
