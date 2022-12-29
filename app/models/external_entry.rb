# frozen_string_literal: true

class ExternalEntry < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

  belongs_to :user

  validates :title, presence: true
  validates :url, presence: true
  validates :published_at, presence: true

  def thumbnail_url
    thumbnail_image_url.presence || image_url('/images/external_entries/thumbnails/blank.svg')
  end
end
