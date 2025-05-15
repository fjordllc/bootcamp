# frozen_string_literal: true

require 'test_helper'

class TranscodeJobTest < ActiveJob::TestCase
  DEFAULT_JOB_NAME = 'jobs/123'

  setup do
    @movie = movies(:movie1)
  end

  def with_production_env(&block)
    Rails.stub :env, ActiveSupport::StringInquirer.new('production'), &block
  end

  def build_client_mock(state)
    client_mock = Minitest::Mock.new
    client_mock.expect :fetch, OpenStruct.new(state:), [DEFAULT_JOB_NAME]
    client_mock
  end

  test 'does nothing in non-production environments' do
    assert_no_enqueued_jobs { TranscodeJob.perform_now(@movie) }
  end

  test 'starts job and enqueues polling job when job_name is nil' do
    Transcoder::Client.stub :new, OpenStruct.new(start: OpenStruct.new(name: DEFAULT_JOB_NAME)) do
      with_production_env do
        assert_enqueued_with(job: TranscodeJob, args: [@movie, DEFAULT_JOB_NAME]) do
          TranscodeJob.perform_now(@movie)
        end
      end
    end
  end

  test 'when job is SUCCEEDED, calls attacher' do
    client_mock = build_client_mock(:SUCCEEDED)

    attacher_mock = Minitest::Mock.new
    attacher_mock.expect :perform, nil

    Transcoder::Client.stub :new, client_mock do
      Transcoder::Attacher.stub :new, attacher_mock do
        with_production_env do
          assert_no_enqueued_jobs do
            TranscodeJob.perform_now(@movie, DEFAULT_JOB_NAME)
          end
        end
      end
    end

    client_mock.verify
    attacher_mock.verify
  end

  test 'when job is FAILED or CANCELLED, does not enqueue another job' do
    %i[FAILED CANCELLED].each do |state|
      client_mock = build_client_mock(state)
      Transcoder::Client.stub :new, client_mock do
        with_production_env do
          assert_no_enqueued_jobs { TranscodeJob.perform_now(@movie, DEFAULT_JOB_NAME) }
        end
      end
      client_mock.verify
    end
  end

  test 'when job is in intermediate state, re-enqueues job' do
    %i[PENDING RUNNING].each do |state|
      client_mock = build_client_mock(state)
      Transcoder::Client.stub :new, client_mock do
        with_production_env do
          assert_enqueued_with(job: TranscodeJob, args: [@movie, DEFAULT_JOB_NAME]) do
            TranscodeJob.perform_now(@movie, DEFAULT_JOB_NAME)
          end
        end
      end
      client_mock.verify
    end
  end
end
