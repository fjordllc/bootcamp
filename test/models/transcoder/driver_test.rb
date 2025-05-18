# frozen_string_literal: true

require 'test_helper'

module Transcoder
  class DriverTest < ActiveSupport::TestCase
    DEFAULT_JOB_NAME = 'jobs/123'

    setup do
      @movie = movies(:movie1)
    end

    test 'creates job and schedules polling when job_name is nil' do
      client_mock = Minitest::Mock.new
      client_mock.expect :create_job, DEFAULT_JOB_NAME

      set_mock = Minitest::Mock.new
      set_mock.expect :perform_later, nil, [@movie, DEFAULT_JOB_NAME]

      Transcoder::Client.stub :new, client_mock do
        TranscodeJob.stub :set, ->(*) { set_mock } do
          Rails.stub :env, ActiveSupport::StringInquirer.new('production') do
            driver = Driver.new(@movie)
            driver.call
          end
        end
      end
      client_mock.verify
      set_mock.verify
    end

    test 'schedules polling when job state is RUNNING or PENDING' do
      %i[RUNNING PENDING].each do |state|
        client_mock = Minitest::Mock.new
        client_mock.expect :fetch_job_state, state, [DEFAULT_JOB_NAME]

        set_mock = Minitest::Mock.new
        set_mock.expect :perform_later, nil, [@movie, DEFAULT_JOB_NAME]

        Transcoder::Client.stub :new, client_mock do
          TranscodeJob.stub :set, ->(*) { set_mock } do
            Rails.stub :env, ActiveSupport::StringInquirer.new('production') do
              driver = Driver.new(@movie, DEFAULT_JOB_NAME)
              driver.call
            end
          end
        end
        client_mock.verify
        set_mock.verify
      end
    end

    test 'logs error when job state is FAILED or CANCELLED' do
      %i[FAILED CANCELLED].each do |state|
        client_mock = Minitest::Mock.new
        client_mock.expect :fetch_job_state, state, [DEFAULT_JOB_NAME]

        error_message = if state == :FAILED
                          "Transcoding failed for Movie #{@movie.id}"
                        else
                          "Transcoding job for Movie #{@movie.id} was cancelled."
                        end

        logger_mock = Minitest::Mock.new
        logger_mock.expect :error, nil, [error_message]

        Rails.stub :env, ActiveSupport::StringInquirer.new('production') do
          Transcoder::Client.stub :new, client_mock do
            Rails.logger.stub :error, ->(msg) { logger_mock.error(msg) } do
              driver = Transcoder::Driver.new(@movie, DEFAULT_JOB_NAME)
              driver.call
            end
          end
        end
        client_mock.verify
        logger_mock.verify
      end
    end

    test 'logs warning on unknown state' do
      client_mock = Minitest::Mock.new
      client_mock.expect :fetch_job_state, :UNKNOWN_STATE, [DEFAULT_JOB_NAME]

      logger_mock = Minitest::Mock.new
      logger_mock.expect :warn, nil, [String]

      Transcoder::Client.stub :new, client_mock do
        Rails.logger.stub :warn, lambda { |msg|
          assert_match(/Unknown transcoder job state: UNKNOWN_STATE/, msg)
        } do
          Rails.stub :env, ActiveSupport::StringInquirer.new('production') do
            driver = Driver.new(@movie, DEFAULT_JOB_NAME)
            driver.call
          end
        end
      end
      client_mock.verify
    end

    test 'does nothing if not production' do
      Transcoder::Client.stub :new, ->(_) { flunk 'Should not be called' } do
        Rails.stub :env, ActiveSupport::StringInquirer.new('development') do
          driver = Driver.new(@movie)
          driver.call
        end
      end
    end
  end
end
