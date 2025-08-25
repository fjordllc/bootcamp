# frozen_string_literal: true
require "test_helper"

class ProcessTranscodingNotificationTest < ActiveSupport::TestCase
  def build_message(data)
    {
      "message" => {
        "data" => Base64.encode64(data.to_json)
      }
    }.to_json
  end

  setup do
    @movie = movies(:movie1)
  end

  test "SUCCEEDED job calls attach_transcoded_file" do
    body = build_message({ "job" => { "name" => "job-1", "state" => "SUCCEEDED" } })
    interactor = ProcessTranscodingNotification.new(body: body)

    attach_called = false
    interactor.stub(:find_movie, @movie) do
      interactor.stub(:attach_transcoded_file, ->(*) { attach_called = true }) do
        interactor.call
      end
    end

    assert attach_called, "attach_transcoded_file should be called for SUCCEEDED jobs"
  end

  test "job with missing name fails with retryable=false" do
    body = build_message({ "job" => { "state" => "SUCCEEDED" } })
    interactor = ProcessTranscodingNotification.new(body: body)

    error = assert_raises(Interactor::Failure) { interactor.call }
    failure_context = error.context

    assert_equal false, failure_context.retryable
    assert_equal "Pub/Sub message missing required job fields: name=, state=SUCCEEDED", failure_context.error
  end

  test "job with unknown movie fails with retryable=false" do
    body = build_message({ "job" => { "name" => "unknown", "state" => "SUCCEEDED" } })
    interactor = ProcessTranscodingNotification.new(body: body)

    error = assert_raises(Interactor::Failure) do
      interactor.stub(:find_movie, nil) { interactor.call }
    end
    failure_context = error.context

    assert failure_context.failure?
    refute failure_context.retryable
  end

  test "FAILED job with unexpected error is retryable" do
    body = build_message({
      "job" => {
        "name" => "job-1",
        "state" => "FAILED",
        "error" => {
          "details" => [{ "fieldViolations" => [{ "description" => "Unexpected error" }] }]
        }
      }
    })
    interactor = ProcessTranscodingNotification.new(body: body)

    error = assert_raises(Interactor::Failure) { interactor.call }
    failure_context = error.context

    assert failure_context.failure?
    assert failure_context.retryable, "Unexpected errors should be retryable"
  end

  test "invalid JSON fails with retryable=false" do
    body = "{ invalid json"
    interactor = ProcessTranscodingNotification.new(body: body)

    error = assert_raises(Interactor::Failure) { interactor.call }
    failure_context = error.context

    assert failure_context.failure?
    refute failure_context.retryable
  end

  test "get_movie_id raises Google::Cloud::Error is retryable" do
    body = build_message({ "job" => { "name" => "job-1", "state" => "SUCCEEDED" } })
    interactor = ProcessTranscodingNotification.new(body: body)

    error = assert_raises(Interactor::Failure) do
      interactor.stub(:find_movie, ->(*) { raise Google::Cloud::Error, "boom" }) do
        interactor.call
      end
    end
    failure_context = error.context

    assert failure_context.failure?
    assert failure_context.retryable
  end

  test "FAILED job with AudioMissing error triggers TranscodeJob.perform_later" do
    body = build_message({
      "job" => {
        "name" => "job-1",
        "state" => "FAILED",
        "error" => {
          "details" => [{ "fieldViolations" => [{ "description" => "AudioMissing" }] }]
        }
      }
    })
    interactor = ProcessTranscodingNotification.new(body: body)

    perform_later_called = false
    interactor.stub(:find_movie, @movie) do
      TranscodeJob.stub(:perform_later, ->(*) { perform_later_called = true }) do
        interactor.call rescue nil
      end
    end

    assert perform_later_called, "AudioMissing error should trigger TranscodeJob.perform_later"
  end
end
