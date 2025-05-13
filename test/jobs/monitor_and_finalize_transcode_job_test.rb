# frozen_string_literal: true

require "test_helper"
require "google/cloud/storage"

class MonitorAndFinalizeTranscodeJobTest < ActiveJob::TestCase
  def setup
    @movie = movies(:movie1)
    @job_instance = MonitorAndFinalizeTranscodeJob.new

    @file_mock = Minitest::Mock.new
    @file_mock.expect :delete, true

    @bucket_mock = Minitest::Mock.new
    @bucket_mock.expect :file, @file_mock, ["#{@movie.id}/muxed-stream.mp4"]

    @storage_mock = Minitest::Mock.new
    @storage_mock.expect :bucket, @bucket_mock, [@job_instance.send(:bucket_name)]

    @io_mock = StringIO.new("dummy_data")
  end

  def run_job_with_state(state)
    transcoder_mock = Minitest::Mock.new
    transcoder_mock.expect(:get_job, OpenStruct.new(state: state)) { true }

    @io_mock.rewind

    @job_instance.stub(:transcoder_client, transcoder_mock) do
      @job_instance.stub(:production_only, ->(&block) { block.call }) do
        Google::Cloud::Storage.stub(:new, @storage_mock) do
          URI.stub(:open, @io_mock) do
            yield if block_given?
            @job_instance.perform(@movie, "dummy_job")
          end
        end
      end
    end

    transcoder_mock.verify
  end

  test "attaches movie file and deletes source on success" do
    @movie.movie_data.attach(
      io: @io_mock,
      filename: "dummy.mp4",
      content_type: "video/mp4"
    )

    assert_nothing_raised { run_job_with_state(:SUCCEEDED) }

    @file_mock.verify
    @bucket_mock.verify
    @storage_mock.verify
  end

  test "enqueues job again if state is PROCESSING" do
    transcoder_mock = Minitest::Mock.new
    transcoder_mock.expect(:get_job, OpenStruct.new(state: :PROCESSING)) { true }
  
    job_double = Minitest::Mock.new
    job_double.expect(:perform_later, true, [@movie, "dummy_job"])
  
    MonitorAndFinalizeTranscodeJob.stub(:set, ->(wait:) { job_double }) do
      @job_instance.stub(:transcoder_client, transcoder_mock) do
        @job_instance.stub(:production_only, ->(&block) { block.call }) do
          Google::Cloud::Storage.stub(:new, @storage_mock) do
            URI.stub(:open, @io_mock) do
              @job_instance.perform(@movie, "dummy_job")
            end
          end
        end
      end
    end
    transcoder_mock.verify
    job_double.verify
  end
end
