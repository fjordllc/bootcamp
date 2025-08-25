# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

class TranscodeJobTest < ActiveJob::TestCase
  setup do
    @movie = OpenStruct.new(id: 1)
    Rails.application.config.transcoder['enabled'] = true
  end

  test 'calls transcode on Transcoder::Client' do
    Transcoder::Client.stub :new, OpenStruct.new(transcode: nil) do
      TranscodeJob.perform_now(@movie, force_video_only: true)
    end
  end

  test 'does not perform when transcoder is disabled' do
    Rails.application.config.transcoder['enabled'] = false

    Transcoder::Client.stub :new, ->(*) { flunk 'should not be called' } do
      TranscodeJob.perform_now(@movie)
    end

    Rails.application.config.transcoder['enabled'] = true
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

  test 'logs and notifies on non-retryable error' do
    error = StandardError.new('permanent failure')

    logged = []
    Rails.logger.stub :error, ->(msg) { logged << msg } do
      @notified = false
      if defined?(Rollbar)
        Rollbar.stub :error, ->(_e, _opts) { @notified = true } do
          TranscodeJob.new(@movie).send(:handle_transcode_error, error, @movie)
        end
      else
        TranscodeJob.new(@movie).send(:handle_transcode_error, error, @movie)
      end
    end

    assert @notified if defined?(Rollbar)
    assert(logged.any? { |msg| msg.include?('Transcoding failed') })
  end

  test 'calculate_retry_wait returns value within jittered range' do
    job = TranscodeJob.new(@movie)
    wait = job.send(:calculate_retry_wait, 0)
    # BASE_WAIT = 30秒, ±10% jitter
    assert wait >= 27 && wait <= 33
  end
end
