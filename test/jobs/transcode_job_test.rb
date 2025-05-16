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

  def build_client_mock(state:)
    client_mock = Minitest::Mock.new
    client_mock.expect :fetch_job_state, state, [DEFAULT_JOB_NAME]
    client_mock
  end

  test 'does nothing in non-production environments' do
    assert_no_enqueued_jobs { TranscodeJob.perform_now(@movie) }
  end

  test 'create job and enqueues polling job when job_name is nil' do
    Transcoder::Client.stub :new, OpenStruct.new(create_job: OpenStruct.new(name: DEFAULT_JOB_NAME)) do
      with_production_env do
        assert_enqueued_with(job: TranscodeJob, args: [@movie, DEFAULT_JOB_NAME]) do
          TranscodeJob.perform_now(@movie)
        end
      end
    end
  end

  test 'calls Attacher for SUCCEEDED' do
    client_mock = build_client_mock(state: :SUCCEEDED)

    Transcoder::Client.stub :new, client_mock do
      attacher_mock = Minitest::Mock.new
      attacher_mock.expect :perform, true

      Transcoder::Attacher.stub :new, attacher_mock do
        with_production_env do
          assert_no_enqueued_jobs do
            TranscodeJob.perform_now(@movie, DEFAULT_JOB_NAME)
          end
        end
      end
      attacher_mock.verify
    end
    client_mock.verify
  end

  test 'does not enqueue job again on FAILED and CANCELLED states' do
    %i[FAILED CANCELLED].each do |state|
      client_mock = build_client_mock(state:)

      Transcoder::Client.stub :new, client_mock do
        with_production_env do
          assert_no_enqueued_jobs do
            TranscodeJob.perform_now(@movie, DEFAULT_JOB_NAME)
          end
        end
      end
      client_mock.verify
    end
  end

  test 'when job is in intermediate state, re-enqueues job' do
    %i[PENDING RUNNING].each do |state|
      client_mock = build_client_mock(state:)

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
