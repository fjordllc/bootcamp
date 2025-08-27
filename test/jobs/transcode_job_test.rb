# frozen_string_literal: true

require 'test_helper'
require 'ostruct'
require 'google/cloud/errors'

class TranscodeJobTest < ActiveJob::TestCase
  setup do
    @movie = movies(:movie1)
    Rails.application.config.transcoder['enabled'] = true
  end

  test 'calls transcode on Transcoder::Client' do
    Transcoder::Client.stub :new, OpenStruct.new(transcode: nil) do
      TranscodeJob.perform_now(@movie, force_video_only: true)
    end
  end

  test 'does not perform when transcoder is disabled' do
    Rails.application.config.transcoder['enabled'] = false
    begin
      Transcoder::Client.stub :new, ->(*) { flunk 'should not be called' } do
        TranscodeJob.perform_now(@movie)
      end
    ensure
      Rails.application.config.transcoder['enabled'] = true
    end
  end

  test 'retries on retryable Google::Cloud::Error' do
    error = Google::Cloud::Error.new('temporary failure')
    def code = 429

    job = TranscodeJob.new(@movie)
    job.stub :executions, 0 do
      job.stub :retryable?, true do
        job.stub :retry_job, ->(wait:) { @retry_called = wait } do
          job.send(:handle_transcode_error, error, @movie)
        end
      end
    end

    assert @retry_called.present?, 'retry_job should be called'
  end

  test 'logs on non-retryable error' do
    error = StandardError.new('permanent failure')

    logged = nil
    Rails.logger.stub :error, ->(msg) { logged = msg } do
      TranscodeJob.new(@movie).send(:handle_transcode_error, error, @movie)
    end

    assert_includes logged, 'permanent failure'
  end

  test 'calculate_retry_wait returns value within jittered range' do
    job = TranscodeJob.new(@movie)
    wait = job.send(:calculate_retry_wait, 0)
    # BASE_WAIT = 30秒, ±10% jitter
    assert wait >= 27 && wait <= 33
  end
end
