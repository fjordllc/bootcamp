# frozen_string_literal: true

class Article < ApplicationRecord
  belongs_to :user
  include ActionView::Helpers::AssetUrlHelper

  THUMBNAIL_SIZE = '1200x630>'
  has_one_attached :thumbnail

  validates :title, presence: true
  validates :body, presence: true
  validates :thumbnail, content_type: %w[image/png image/jpg image/jpeg], size: { less_than: 10.megabytes }

  paginates_per 10
  acts_as_taggable

  def resize_thumbnail!
    thumbnail.variant(resize: THUMBNAIL_SIZE).processed if thumbnail.attached?
  end

  def thumbnail_url
    if thumbnail.attached?
      thumbnail.variant(resize: THUMBNAIL_SIZE).service_url
    else
      image_url('/images/articles/thumbnails/default.png')
    end
  end
end
