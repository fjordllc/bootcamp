# frozen_string_literal: true

class Movie < ApplicationRecord
  include Searchable
  include WithAvatar
  include Taggable
  include Reactionable
  include Commentable
  include Watchable
  include Bookmarkable

  THUMBNAIL_SIZE = [1200, 630].freeze

  belongs_to :user
  has_many :practices_movies, dependent: :nullify
  has_many :practices, through: :practices_movies
  has_one_attached :movie_data
  has_one_attached :thumbnail

  validates :user, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :movie_data, presence: true
  validates :thumbnail,
            content_type: %w[image/png image/jpeg],
            size: { less_than: 10.megabytes }

  scope :wip, -> { where(wip: true) }
  scope :by_tag, ->(tag) { tag.present? ? tagged_with(tag) : all }

  after_create_commit :start_transcode_job, on: :create
  after_create_commit :generate_default_thumbnail, on: :create

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description wip created_at updated_at user_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user practices comments reactions watches bookmarks]
  end

  def thumbnail_url
    if thumbnail.attached?
      thumbnail.variant(resize_to_fill: THUMBNAIL_SIZE).processed.url
    else
      ActionController::Base.helpers.asset_path('work-blank.svg')
    end
  end

  private

  def start_transcode_job
    TranscodeJob.perform_later(self)
  rescue StandardError => e
    Rails.logger.error("Failed to enqueue TranscodeJob for Movie #{id}: #{e.message}")
    raise
  end

  def generate_default_thumbnail
    GenerateMovieThumbnailJob.perform_later(self)
  rescue StandardError => e
    Rails.logger.error("Failed to enqueue GenerateMovieThumbnailJob for Movie #{id}: #{e.message}")
    raise
  end
end
