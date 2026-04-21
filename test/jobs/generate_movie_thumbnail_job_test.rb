# frozen_string_literal: true

require 'test_helper'

class GenerateMovieThumbnailJobTest < ActiveJob::TestCase
  test 'attaches first frame image as thumbnail' do
    movie = movies(:movie1)
    movie.thumbnail.purge

    # ActiveStorage の動画プレビュー生成（ffmpeg 経由）が CI 上でまれに一時的に
    # 失敗し、ジョブ内の `rescue ActiveStorage::PreviewError` に握り潰されるため、
    # サムネイルが添付されるまで数回リトライする。
    3.times do
      GenerateMovieThumbnailJob.perform_now(movie)
      break if movie.reload.thumbnail.attached?

      sleep 0.2
    end

    assert movie.thumbnail.attached?
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
