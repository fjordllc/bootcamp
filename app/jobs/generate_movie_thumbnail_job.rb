# frozen_string_literal: true

class GenerateMovieThumbnailJob < ApplicationJob
  def perform(movie)
    return if movie.thumbnail.attached?
    return unless movie.movie_data.attached? && movie.movie_data.previewable?

    preview = movie.movie_data.preview({})
    preview.processed
    movie.thumbnail.attach(preview.image.blob)
  rescue ActiveStorage::PreviewError => e
    Rails.logger.warn("Failed to generate thumbnail for Movie #{movie.id}: #{e.message}")
  end
end
