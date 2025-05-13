# frozen_string_literal: true

require 'test_helper'
require 'google/cloud/storage'

class MonitorAndFinalizeTranscodeJobTest < ActiveJob::TestCase
  def setup
    @movie = movies(:movie1)
    @job_instance = MonitorAndFinalizeTranscodeJob.new
    @io_mock = StringIO.new('dummy_data')
  end

  def run_job(storage_mock:, transcoder_mock:)
    @io_mock.rewind

    @job_instance.stub(:transcoder_client, transcoder_mock) do
      @job_instance.stub(:production_only, ->(&block) { block.call }) do
        Google::Cloud::Storage.stub(:new, storage_mock) do
          URI.stub(:open, @io_mock) do
            @job_instance.perform(@movie, 'dummy_job')
          end
        end
      end
    end
  end

  test 'attaches movie file and deletes source on SUCCEEDED' do
    file_mock = Minitest::Mock.new
    file_mock.expect :download, StringIO.new('dummy_data')
    file_mock.expect :delete, true

    bucket_mock = Minitest::Mock.new
    bucket_mock.expect :file, file_mock, ["#{@movie.id}/muxed-stream.mp4"]
    bucket_mock.expect :file, file_mock, ["#{@movie.id}/muxed-stream.mp4"]

    storage_mock = Minitest::Mock.new
    storage_mock.expect :bucket, bucket_mock, [@job_instance.send(:bucket_name)]
    storage_mock.expect :bucket, bucket_mock, [@job_instance.send(:bucket_name)]

    transcoder_mock = Minitest::Mock.new
    transcoder_mock.expect(:get_job, OpenStruct.new(state: :SUCCEEDED)) { true }

    assert_nothing_raised do
      run_job(storage_mock:, transcoder_mock:)
    end

    file_mock.verify
    bucket_mock.verify
    storage_mock.verify
  end

  test 'enqueues job again if state is PENDING or RUNNING' do
    %i[PENDING RUNNING].each do |state|
      transcoder_mock = Minitest::Mock.new
      transcoder_mock.expect(:get_job, OpenStruct.new(state:)) { true }

      storage_mock = Minitest::Mock.new

      job_double = Minitest::Mock.new
      job_double.expect(:perform_later, true, [@movie, 'dummy_job'])

      MonitorAndFinalizeTranscodeJob.stub(:set, ->(**) { job_double }) do
        run_job(storage_mock:, transcoder_mock:)
      end

      transcoder_mock.verify
      job_double.verify
    end
  end
end
