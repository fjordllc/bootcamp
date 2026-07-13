# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :image, attached: true
end
