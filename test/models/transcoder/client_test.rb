# frozen_string_literal: true

require 'test_helper'

module Transcoder
  class ClientTest < ActiveSupport::TestCase
    setup do
      @valid_movie = OpenStruct.new(id: 1, movie_data: OpenStruct.new(blob: OpenStruct.new(key: 'dummy.mp4')))
      @valid_config = {
        'location' => 'us-central1',
        'pubsub_topic' => 'topic',
        'video_height' => 720,
        'video_width' => 1280,
        'video_bitrate' => 1_000_000,
        'video_frame_rate' => 30,
        'audio_codec' => 'aac',
        'audio_bitrate' => 128_000,
        'container' => 'mp4'
      }
    end

    private

    def client(force_video_only: false)
      Transcoder::Client.new(@valid_movie, config: @valid_config, bucket_name: 'bucket', project_id: 'proj', force_video_only:)
    end

    def with_transcoder_service(client, list_jobs: [], create_job_proc: nil, get_job_proc: nil)
      client.define_singleton_method(:transcoder_service) do
        Object.new.tap do |service|
          service.define_singleton_method(:list_jobs) { |*| list_jobs }
          service.define_singleton_method(:create_job) { |**args| create_job_proc&.call(args) }
          service.define_singleton_method(:get_job) { |**args| get_job_proc&.call(args) }
        end
      end
    end

    test 'bucket_name required' do
      error = assert_raises(ArgumentError) { Transcoder::Client.new(@valid_movie, config: @valid_config, bucket_name: nil, project_id: 'proj') }
      assert_equal 'bucket_name is required', error.message
    end

    test 'project_id required' do
      error = assert_raises(ArgumentError) { Transcoder::Client.new(@valid_movie, config: @valid_config, bucket_name: 'bucket', project_id: nil) }
      assert_equal 'project_id is required', error.message
    end

    test 'location required in config' do
      config = @valid_config.dup
      config['location'] = nil
      error = assert_raises(ArgumentError) { Transcoder::Client.new(@valid_movie, config:, bucket_name: 'bucket', project_id: 'proj') }
      assert_equal 'location is required', error.message
    end

    test 'pubsub_topic required in config' do
      config = @valid_config.dup
      config['pubsub_topic'] = nil
      error = assert_raises(ArgumentError) { Transcoder::Client.new(@valid_movie, config:, bucket_name: 'bucket', project_id: 'proj') }
      assert_equal 'pubsub_topic is required', error.message
    end

    test '#transcode creates job' do
      c = client
      job_created = false
      with_transcoder_service(c, list_jobs: [], create_job_proc: ->(_args) { job_created = true })
      c.transcode
      assert job_created, 'A new job should be created when no existing job'
    end

    test '#transcode skips if job exists' do
      c = client
      job_created = false
      with_transcoder_service(c, list_jobs: [OpenStruct.new(labels: { 'movie_id' => @valid_movie.id.to_s }, state: 'RUNNING')],
                                 create_job_proc: ->(_args) { job_created = true })
      c.transcode
      assert_not job_created
    end

    test '#transcode raises on failure' do
      c = client
      with_transcoder_service(c, list_jobs: [], create_job_proc: ->(_args) { raise Google::Cloud::Error, 'API failed' })
      error = assert_raises(Google::Cloud::Error) { c.transcode }
      assert_equal 'API failed', error.message
    end

    test '#transcode force_video_only' do
      c = client(force_video_only: true)
      created_job = nil
      with_transcoder_service(c, list_jobs: [], create_job_proc: ->(args) { created_job = args[:job] })
      c.transcode

      elementary_keys = created_job[:config][:elementary_streams].map { |s| s[:key] }
      assert_equal ['video-stream'], elementary_keys

      mux_keys = created_job[:config][:mux_streams].flat_map { |m| m[:elementary_streams] }
      assert_not_includes mux_keys, 'audio-stream'
    end

    test '#get_movie_id returns id' do
      c = client
      with_transcoder_service(c, get_job_proc: ->(_args) { OpenStruct.new(labels: { 'movie_id' => '123' }) })
      movie_id = c.get_movie_id('job_name_1')
      assert_equal '123', movie_id
    end

    test '#get_movie_id nil if blank' do
      c = client
      assert_nil c.get_movie_id(nil)
      assert_nil c.get_movie_id('')
    end

    test '#get_movie_id nil on error' do
      c = client
      with_transcoder_service(c, get_job_proc: ->(_args) { raise Google::Cloud::Error, 'boom' })
      assert_nil c.get_movie_id('job_name_1')
    end
  end
end
