# frozen_string_literal: true

require "test_helper"

class StartTranscodeJobTest < ActiveJob::TestCase
  test "creates job and enqueues MonitorAndFinalizeTranscodeJob" do
    movie = movies(:movie1)
    job_instance = StartTranscodeJob.new
    transcoder_mock = Minitest::Mock.new
    transcoder_mock.expect(:create_job, OpenStruct.new(name: "dummy_job")) do |args|
      assert_kind_of Hash, args
      assert_includes args.keys, :parent
      assert_includes args.keys, :job
    end

    assert_enqueued_with(job: MonitorAndFinalizeTranscodeJob) do
      job_instance.stub(:transcoder_client, transcoder_mock) do
        job_instance.stub(:production_only, ->(&block) { block.call }) do
          job_instance.perform(movie)
        end
      end
    end
    transcoder_mock.verify
  end
end
