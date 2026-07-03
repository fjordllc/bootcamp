# frozen_string_literal: true

class BulkMovieThumbnailJob < ApplicationJob
  def perform
    Movie.where.missing(:thumbnail_attachment).find_each do |movie|
      GenerateMovieThumbnailJob.perform_later(movie)
    end
  end
end
