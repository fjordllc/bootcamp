# frozen_string_literal: true

require 'test_helper'

class TranscodeJobTest < ActiveJob::TestCase
  test '#perform' do
    movie = movies(:movie1)
    driver_mock = Minitest::Mock.new
    driver_mock.expect :call, true

    Transcoder::Driver.stub :new, ->(_movie, _job_name) { driver_mock } do
      TranscodeJob.new.perform(movie)
    end
    driver_mock.verify
  end
end
