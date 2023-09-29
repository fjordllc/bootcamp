# frozen_string_literal: true

class Article < ApplicationRecord
  enum thumbnail_type: { prepared_thumbnail: 0,
                         ruby: 1,
                         ruby_on_rails: 2,
                         javascript: 3,
                         wsl2: 4,
                         linux: 5,
                         pc: 6,
                         sponsorship: 7,
                         green: 8,
                         purple: 9,
                         orange: 10,
                         brown: 11,
                         blue: 12 }

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
      image_url("/ogp/#{thumbnail_type}.png")
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
