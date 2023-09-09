# frozen_string_literal: true

class Post < ActiveRecord::Base
  include PluckToStruct

  belongs_to :author
  has_many :comments
end
