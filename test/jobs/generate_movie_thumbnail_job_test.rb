# frozen_string_literal: true

require 'test_helper'

class GenerateMovieThumbnailJobTest < ActiveJob::TestCase
  test 'attaches first frame image as thumbnail' do
    movie = movies(:movie1)
    movie.thumbnail.purge
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )

    GenerateMovieThumbnailJob.perform_now(movie)

    assert movie.reload.thumbnail.attached?
    assert_equal 'image/jpeg', movie.thumbnail.content_type
  end

  test 'does not overwrite existing thumbnail' do
    movie = movies(:movie1)
    movie.thumbnail.attach(
      io: File.open(Rails.root.join('test/fixtures/files/articles/ogp_images/test.jpg')),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )
    thumbnail_blob_id = movie.thumbnail.blob_id

    GenerateMovieThumbnailJob.perform_now(movie)

    assert_equal thumbnail_blob_id, movie.reload.thumbnail.blob_id
  end
end
