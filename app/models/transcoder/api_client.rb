# frozen_string_literal: true

module Transcoder
  class ApiClient
    def initialize(movie, config: nil, bucket_name: nil, project_id: nil)
      @movie = movie
      @config = config || default_config
      @bucket_name = bucket_name || default_bucket_name
      @project_id = project_id || default_project_id
    end

    def create_job
      transcoder_service.create_job(
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
                        .name
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
              height_pixels: @config['video_height'],
              width_pixels: @config['video_width'],
              bitrate_bps: @config['video_bitrate'],
              frame_rate: @config['video_frame_rate']
            }
          }
        },
        {
          key: 'audio-stream',
          audio_stream: {
            codec: @config['audio_codec'],
            bitrate_bps: @config['audio_bitrate']
          }
        }
      ]
    end

    def mux_streams
      [
        {
          key: 'muxed-stream',
          container: @config['container'],
          elementary_streams: %w[video-stream audio-stream]
        }
      ]
    end

    def transcoder_service
      Google::Cloud::Video::Transcoder.transcoder_service
    end

    def location
      config['location']
    end

    def service_name
      ActiveStorage::Blob.service.name.to_s
    end

    def default_bucket_name
      Rails.application.config.active_storage.service_configurations[service_name]['bucket']
    end

    def default_project_id
      Rails.application.config.active_storage.service_configurations[service_name]['project']
    end

    def input_uri
      "gs://#{bucket_name}/#{@movie.movie_data.key}"
    end

    def output_uri
      "gs://#{bucket_name}/#{@movie.id}/"
    end

    def parent_path
      "projects/#{project_id}/locations/#{location}"
    end

    def get_job(job_name)
      transcoder_service.get_job(name: job_name)
    end

    def default_config
      Rails.application.config.transcoder
    end
  end
end
