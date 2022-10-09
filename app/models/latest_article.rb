# frozen_string_literal: true

class LatestArticle < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

  THUMBNAIL_SIZE = '88x88>'
  has_one_attached :thumbnail
  belongs_to :user

  validates :title, presence: true
  validates :url, presence: true

  def thumbnail_url
    if thumbnail.attached?
      thumbnail.variant(resize: THUMBNAIL_SIZE).processed.url
    else
      image_url('/images/latest_articles/thumbnails/default.png')
    end
  end
end
