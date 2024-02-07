# frozen_string_literal: true

class Article < ApplicationRecord
  enum thumbnail_type: { prepared_thumbnail: 0,
                         Ruby: 1,
                         Ruby_on_Rails: 2,
                         JavaScript: 3,
                         WSL2: 4,
                         Linux: 5,
                         advise: 6,
                         school_information: 7 }

  belongs_to :user
  include ActionView::Helpers::AssetUrlHelper

  THUMBNAIL_SIZE = '1200x630>'
  has_one_attached :thumbnail

  before_validation :set_published_at, if: :will_be_published?

  validates :title, presence: true
  validates :body, presence: true
  validates :thumbnail_type, presence: true
  validates :published_at, presence: true, if: :will_be_published?
  validates :thumbnail,
            content_type: %w[image/png image/jpg image/jpeg],
            size: { less_than: 10.megabytes }

  paginates_per 24
  acts_as_taggable

  def prepared_thumbnail_url
    if thumbnail.attached?
      thumbnail.variant(resize: THUMBNAIL_SIZE).processed.url
    else
      image_url('/assets/articles/thumbnails/default.png')
    end
  end

  def selected_thumbnail_url
    if Rails.env.production?
      image_url("https://bootcamp.fjord.jp/public/images/ogp/#{thumbnail_type}.png")
    else
      image_url("/images/ogp/#{thumbnail_type}.png")
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
