# frozen_string_literal: true

require 'test_helper'

module Transcoder
  class ClientTest < ActiveSupport::TestCase
    DEFAULT_JOB_NAME = 'jobs/123'

    def setup
      @movie = movies(:movie1)
      @mock_service = Object.new
    end

    test '#create_job' do
      @mock_service.define_singleton_method(:create_job) do |parent:, job:|
        _parent = parent
        _job = job
        OpenStruct.new(name: DEFAULT_JOB_NAME)
      end

      Google::Cloud::Video::Transcoder.stub :transcoder_service, @mock_service do
        client = Transcoder::Client.new(@movie)
        response = client.create_job
        assert_equal DEFAULT_JOB_NAME, response.name
      end
    end

    test '#get_job' do
      @mock_service.define_singleton_method(:get_job) do |name:|
        OpenStruct.new(name:)
      end

      Google::Cloud::Video::Transcoder.stub :transcoder_service, @mock_service do
        client = Transcoder::Client.new(@movie)
        response = client.get_job(DEFAULT_JOB_NAME)
        assert_equal DEFAULT_JOB_NAME, response.name
      end
    end
  end
end
