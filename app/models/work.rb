# frozen_string_literal: true

class Work < ApplicationRecord
  THUMBNAIL_SIZE = "1200x630>"
  belongs_to :user
  has_one_attached :thumbnail
  scope :graduation_works, -> { where(graduation_work: true) }

  validates :user, presence: true
  validates :title, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :description, presence: true
  validates :url_or_repository, presence: true
  validates :thumbnail,
    content_type: %w(image/png image/jpg image/jpeg),
    size: { less_than: 10.megabytes }

  def resize_thumbnail!
    if thumbnail.attached?
      thumbnail.variant(resize: THUMBNAIL_SIZE).processed
    end
  end

  def thumbnail_url
    if thumbnail.attached?
      thumbnail.variant(resize: THUMBNAIL_SIZE).service_url
    else
      image_url("/images/works/thumbnails/default.png")
    end
  end

  private

    def url_or_repository
      url.presence || repository.presence
    end
end
