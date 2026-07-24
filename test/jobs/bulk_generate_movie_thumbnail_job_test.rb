# frozen_string_literal: true

require 'test_helper'

class BulkGenerateMovieThumbnailJobTest < ActiveJob::TestCase
  test 'generates thumbnails synchronously for movies without one' do
    movie = movies(:movie1)
    movie.thumbnail.purge
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )

    BulkGenerateMovieThumbnailJob.perform_now

    assert movie.reload.thumbnail.attached?
  end
end
