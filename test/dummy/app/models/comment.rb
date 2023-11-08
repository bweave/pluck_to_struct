# frozen_string_literal: true

class Comment < ApplicationRecord
  include PluckToStruct

  belongs_to :author
  belongs_to :post
end
