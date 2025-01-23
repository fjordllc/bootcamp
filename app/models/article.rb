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

  enum target: {
    all: 0,
    students: 1,
    job_seekers: 2,
    none: 3
  }, _prefix: true

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
            content_type: %w[image/png image/jpeg],
            size: { less_than: 10.megabytes }

  paginates_per 24
  acts_as_taggable

  scope :with_attachments_and_user, lambda {
    with_attached_thumbnail.includes(user: { avatar_attachment: :blob }).where(wip: false)
  }

  scope :featured, -> { tagged_with('注目の記事').order(published_at: :desc).where(wip: false).limit(6) }

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

  def before_initial_publish?
    attribute_in_database(:published_at).nil?
  end

  def generate_token!
    self.token ||= SecureRandom.urlsafe_base64
  end

  private

  def will_be_published?
    !wip && before_initial_publish?
  end

  def set_published_at
    self.published_at = Time.current
  end
end
