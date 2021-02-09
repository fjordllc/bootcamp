# frozen_string_literal: true

class ReferenceBook < ApplicationRecord
  COVER_SIZE = '100x150>'
  belongs_to :practice
  has_one_attached :cover
  validates :title, presence: true
  validates :price, presence: true, numericality: { only_integer: true }
  validates :page_url, presence: true
  validates :cover,
            content_type: %w[image/png image/jpg image/jpeg],
            size: { less_than: 10.megabytes }

  def cover_url
    cover.variant(resize: COVER_SIZE).processed
  end
end
