# frozen_string_literal: true
require 'tempfile'

class Movie < ApplicationRecord
  include Searchable
  include WithAvatar
  include Taggable
  include Reactionable
  include Commentable
  include Watchable
  include Bookmarkable

  belongs_to :user
  has_many :practices_movies, dependent: :nullify
  has_many :practices, through: :practices_movies
  has_one_attached :movie_data

  validates :user, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :movie_data, presence: true

  scope :wip, -> { where(wip: true) }

  after_create_commit :start_transcode_job, on: :create

  def has_audio?
    return @has_audio unless @has_audio.nil?

    return false unless movie_data.attached?

    temp_file = Tempfile.new(['movie', File.extname(movie_data.filename.to_s)])
    temp_file.binmode
    temp_file.write(movie_data.download)
    temp_file.close

    begin
      movie = FFMPEG::Movie.new(temp_file.path)
      @has_audio = movie.audio_streams.any?
    rescue => e
      Rails.logger.error("has_audio? error: #{e.message}")
      @has_audio = false
    ensure
      temp_file.unlink
    end
  end

  private

  def start_transcode_job
    TranscodeJob.perform_later(self)
  rescue StandardError => e
    Rails.logger.error("Failed to enqueue TranscodeJob for Movie #{id}: #{e.message}")
    raise
  end
end
