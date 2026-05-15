# frozen_string_literal: true

class GenerateMovieThumbnailJob < ApplicationJob
  retry_on ActiveStorage::PreviewError, wait: :polynomially_longer, attempts: 3

  def perform(movie)
    return if movie.thumbnail.attached?
    return unless movie.movie_data.attached? && movie.movie_data.previewable?

    preview = movie.movie_data.preview({})
    preview.processed
    movie.thumbnail.attach(preview.image.blob)
  end
end
