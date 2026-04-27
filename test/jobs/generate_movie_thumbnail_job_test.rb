# frozen_string_literal: true

require 'test_helper'

class GenerateMovieThumbnailJobTest < ActiveJob::TestCase
  test 'attaches first frame image as thumbnail' do
    movie = movies(:movie1)
    movie.thumbnail.purge
    preview_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('test/fixtures/files/articles/ogp_images/test.jpg')),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )
    preview = Minitest::Mock.new
    preview.expect(:processed, preview)
    preview.expect(:image, Struct.new(:blob).new(preview_blob))

    movie.movie_data.stub(:previewable?, true) do
      movie.movie_data.stub(:preview, preview) do
        GenerateMovieThumbnailJob.perform_now(movie)
      end
    end

    preview.verify
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
