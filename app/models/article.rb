# frozen_string_literal: true

class Article < ApplicationRecord
  enum thumbnail_type: {
    prepared_thumbnail: 0,
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
    blue: 12
  }

  belongs_to :user
  alias sender user
  include ActionView::Helpers::AssetUrlHelper

  THUMBNAIL_SIZE = [1200, 630].freeze
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

  def prepared_thumbnail_url(thumbnail_size = THUMBNAIL_SIZE)
    if thumbnail.attached?
      thumbnail.variant(resize_to_fill: thumbnail_size).processed.url
    else
      image_url('/ogp/blank.svg')
    end
  end

  def selected_thumbnail_url
    image_url("/ogp/#{thumbnail_type}.png")
  end

  def published?
    !wip?
  end

  def generate_token!
    self.token ||= SecureRandom.urlsafe_base64
    save
  end

  private

  def will_be_published?
    !wip && published_at.nil?
  end

  def set_published_at
    self.published_at = Time.current
  end
end
