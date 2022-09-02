# frozen_string_literal: true

class RelatedBook < ApplicationRecord
  belongs_to :user
  has_one_attached :cover
end
