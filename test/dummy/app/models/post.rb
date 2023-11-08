# frozen_string_literal: true

class Post < ApplicationRecord
  include PluckToStruct

  belongs_to :author
  has_many :comments
end
