# frozen_string_literal: true

class Comment < ActiveRecord::Base
  include PluckToStruct

  belongs_to :post
end
