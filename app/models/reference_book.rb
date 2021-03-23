# frozen_string_literal: true

class ReferenceBook < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

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
    if cover.attached?
      cover.variant(resize: COVER_SIZE).service_url
    else
      image_url('/images/reference_books/covers/default.jpg')
    end
  end

  def resize_cover!
    return unless cover.attached?

    cover.variant(resize: COVER_SIZE).processed
  end
end
