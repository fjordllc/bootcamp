# frozen_string_literal: true

module Transcoder
  class Client
    VIDEO_HEIGHT = 1080
    VIDEO_WIDTH = 1920
    VIDEO_BITRATE = 12_000_000
    VIDEO_FRAME_RATE = 120
    AUDIO_CODEC = 'aac'
    AUDIO_BITRATE = 128_000

    def initialize(movie)
      service_name = ActiveStorage::Blob.service.name.to_s
      @movie = movie
      @client = Google::Cloud::Video::Transcoder.transcoder_service
      @bucket_name = Rails.application.config.active_storage.service_configurations[service_name]['bucket']
      @project_id = Rails.application.config.active_storage.service_configurations[service_name]['project']
      @location = 'asia-northeast1'
    end

    def create_job
      @client.create_job(
        parent: parent_path,
        job: {
          input_uri:,
          output_uri:,
          config: {
            elementary_streams:,
            mux_streams:
          }
        }
      )
    end

    def fetch_job_state(job_name)
      get_job(job_name).state
    end

    private

    def elementary_streams
      [
        {
          key: 'video-stream',
          video_stream: {
            h264: {
              height_pixels: VIDEO_HEIGHT,
              width_pixels: VIDEO_WIDTH,
              bitrate_bps: VIDEO_BITRATE,
              frame_rate: VIDEO_FRAME_RATE
            }
          }
        },
        {
          key: 'audio-stream',
          audio_stream: {
            codec: AUDIO_CODEC,
            bitrate_bps: AUDIO_BITRATE
          }
        }
      ]
    end

    def mux_streams
      [
        {
          key: 'muxed-stream',
          container: 'mp4',
          elementary_streams: %w[video-stream audio-stream]
        }
      ]
    end

    def input_uri
      "gs://#{@bucket_name}/#{@movie.movie_data.key}"
    end

    def output_uri
      "gs://#{@bucket_name}/#{@movie.id}/"
    end

    def parent_path
      "projects/#{@project_id}/locations/#{@location}"
    end

    def get_job(job_name)
      @client.get_job(name: job_name)
    end
  end
end
