# frozen_string_literal: true

class Work < ApplicationRecord
  THUMBNAIL_SIZE = [1200, 630].freeze
  belongs_to :user
  has_one_attached :thumbnail

  validates :user, presence: true
  validates :title, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :description, presence: true
  validates :url_or_repository, presence: true
  validates :url, :repository, :launch_article,
            format: {
              allow_blank: true,
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
              message: 'は「http://example.com」や「https://example.com」のようなURL形式で入力してください'
            }
  validates :thumbnail,
            content_type: %w[image/png image/jpg image/jpeg],
            size: { less_than: 10.megabytes }

  def thumbnail_url
    default_work_thumbnail_path = '/images/works/thumbnails/default.png'
    if thumbnail.attached?
      thumbnail.variant(resize_to_fill: THUMBNAIL_SIZE).processed.url
    else
      image_url(default_work_thumbnail_path)
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::InvariableError
    image_url default_work_thumbnail_path
  end

  private

  def url_or_repository
    url.presence || repository.presence
  end
end
