# frozen_string_literal: true

class ReferenceBook < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

  COVER_SIZE = '100x150>'
  belongs_to :practice
  has_one_attached :cover
  validates :title, presence: true
  validates :price, presence: true, numericality: { only_integer: true }
  validates :page_url, presence: true
  validates :must_read, inclusion: { in: [true, false] }
  validates :cover,
            content_type: %w[image/png image/jpg image/jpeg],
            size: { less_than: 10.megabytes }

  def cover_url
    default_image_path = '/images/reference_books/covers/default.svg'
    if cover.attached?
      cover.variant(resize: COVER_SIZE)
    else
      image_url default_image_path
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::InvariableError
    image_url default_image_path
  end
end
