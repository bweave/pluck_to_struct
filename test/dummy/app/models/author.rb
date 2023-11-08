# frozen_string_literal: true

class Author < ApplicationRecord
  include PluckToStruct

  has_many :posts
  has_many :post_comments, through: :posts, class_name: "Comment"
  has_many :comments
end
