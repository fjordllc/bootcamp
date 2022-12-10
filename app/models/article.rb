# frozen_string_literal: true

class Article < ApplicationRecord
  belongs_to :user
  include ActionView::Helpers::AssetUrlHelper

  THUMBNAIL_SIZE = '1200x630>'
  has_one_attached :thumbnail

  before_validation :set_published_at, if: :will_be_published?

  validates :title, presence: true
  validates :body, presence: true
  validates :published_at, presence: true, if: :will_be_published?
  validates :thumbnail,
            content_type: %w[image/png image/jpg image/jpeg],
            size: { less_than: 10.megabytes }

  paginates_per 24
  acts_as_taggable

  def thumbnail_url
    if thumbnail.attached?
      thumbnail.variant(resize: THUMBNAIL_SIZE).processed.url
    else
      image_url('/images/articles/thumbnails/default.png')
    end
  end

  private

  def will_be_published?
    !wip && published_at.nil?
  end

  def set_published_at
    self.published_at = Time.current
  end
end
