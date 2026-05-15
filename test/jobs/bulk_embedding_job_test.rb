# frozen_string_literal: true

require 'test_helper'

class BulkEmbeddingJobTest < ActiveJob::TestCase
  test 'performs without error when API is not available' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = nil

    assert_nothing_raised do
      BulkEmbeddingJob.perform_now
    end
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'accepts model_name parameter' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = nil

    assert_nothing_raised do
      BulkEmbeddingJob.perform_now(model_name: 'Practice')
    end
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'accepts force_regenerate parameter' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = nil

    assert_nothing_raised do
      BulkEmbeddingJob.perform_now(force_regenerate: true)
    end
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'job is enqueued to default queue' do
    assert_equal 'default', BulkEmbeddingJob.queue_name
  end
end
