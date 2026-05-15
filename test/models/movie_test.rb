# frozen_string_literal: true

require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'enqueues default thumbnail generation after create' do
    movie = Movie.new(
      title: 'サムネイル生成ジョブのテスト',
      description: 'サムネイル生成ジョブのテストです。',
      user: users(:kimura)
    )
    movie.movie_data.attach(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )

    assert_enqueued_with(job: GenerateMovieThumbnailJob) do
      movie.save!
    end
  end

  test 'thumbnail_url returns custom thumbnail when attached' do
    movie = movies(:movie1)
    movie.thumbnail.attach(
      io: File.open(Rails.root.join('test/fixtures/files/articles/ogp_images/test.jpg')),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )

    assert movie.thumbnail.attached?
    assert movie.thumbnail_url.present?
    assert_no_match(/work-blank/, movie.thumbnail_url)
  end

  test 'thumbnail_url returns movie preview when custom thumbnail is not attached' do
    movie = movies(:movie1)
    movie.thumbnail.purge

    assert_match(/work-blank/, movie.thumbnail_url)
  end
end
