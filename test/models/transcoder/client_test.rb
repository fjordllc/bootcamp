# frozen_string_literal: true

require 'test_helper'

module Transcoder
  class ClientTest < ActiveSupport::TestCase
    DEFAULT_JOB_NAME = 'jobs/123'

    def setup
      @movie = movies(:movie1)
      @mock_service = Minitest::Mock.new
    end

    test '#create_job' do
      called_with_parent = nil
      called_with_job = nil

      @mock_service.expect :create_job, OpenStruct.new(name: DEFAULT_JOB_NAME) do |parent:, job:|
        called_with_parent = parent
        called_with_job = job
        true
      end

      Google::Cloud::Video::Transcoder.stub :transcoder_service, @mock_service do
        client = Transcoder::Client.new(@movie)
        response = client.create_job

        assert_equal DEFAULT_JOB_NAME, response
        assert_equal client.send(:parent_path), called_with_parent
        assert_equal client.send(:elementary_streams), called_with_job[:config][:elementary_streams]
        assert_equal client.send(:mux_streams), called_with_job[:config][:mux_streams]
        assert_match(%r{^gs://}, called_with_job[:input_uri])
        assert_match(%r{^gs://}, called_with_job[:output_uri])
      end
      @mock_service.verify
    end

    test '#fetch_job_state' do
      expected_state = :SUCCEEDED

      @mock_service.expect :get_job, OpenStruct.new(state: expected_state) do |**args|
        args == { name: DEFAULT_JOB_NAME }
      end

      Google::Cloud::Video::Transcoder.stub :transcoder_service, @mock_service do
        client = Transcoder::Client.new(@movie)
        state = client.fetch_job_state(DEFAULT_JOB_NAME)
        assert_equal expected_state, state
      end
      @mock_service.verify
    end
  end
end
