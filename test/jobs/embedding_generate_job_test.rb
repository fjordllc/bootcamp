# frozen_string_literal: true

require 'test_helper'

class EmbeddingGenerateJobTest < ActiveJob::TestCase
  test 'performs without error when API is not available' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = nil

    practice = practices(:practice1)
    assert_nothing_raised do
      EmbeddingGenerateJob.perform_now(model_name: 'Practice', record_id: practice.id)
    end
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'handles missing record gracefully' do
    assert_nothing_raised do
      EmbeddingGenerateJob.perform_now(model_name: 'Practice', record_id: -1)
    end
  end

  test 'job is enqueued to default queue' do
    assert_equal 'default', EmbeddingGenerateJob.queue_name
  end
end
