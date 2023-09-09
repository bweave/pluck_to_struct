# frozen_string_literal: true

class Author < ActiveRecord::Base
  include PluckToStruct

  has_many :posts
  has_many :comments, through: :posts
end
