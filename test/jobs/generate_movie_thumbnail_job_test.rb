# frozen_string_literal: true

require 'test_helper'

class GenerateMovieThumbnailJobTest < ActiveJob::TestCase
  test 'attaches first frame image as thumbnail' do
    movie = movies(:movie1)
    movie.thumbnail.purge
    # fixture の attachment レコードだけでは CI のクリーンな DiskService 上に
    # 実ファイルが存在せず `preview.processed` が `ActiveStorage::FileNotFoundError`
    # を投げるため、`movies_test.rb` と同じ方式で実ファイルを明示的に添付する。
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
