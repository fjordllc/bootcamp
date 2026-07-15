# frozen_string_literal: true

require 'test_helper'

class BulkGenerateMovieThumbnailJobTest < ActiveJob::TestCase
  test 'enqueues GenerateMovieThumbnailJob for movies without a thumbnail' do
    movie = movies(:movie1)
    movie.thumbnail.purge

    assert_enqueued_with(job: GenerateMovieThumbnailJob, args: [movie]) do
      BulkGenerateMovieThumbnailJob.perform_now
    end
  end
end
