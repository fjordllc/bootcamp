# frozen_string_literal: true

module Transcoder
  class ApiClient
    
    def initialize(movie, config: nil, bucket_name: nil, project_id: nil)
      @movie = movie
      @config = config || default_config
      @bucket_name = bucket_name || default_storage_config['bucket']
      @project_id = project_id || default_storage_config['project']
    end

    def create_transcoding_job
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
    end

    def succeeded?(job)
      fetch_job_state(job) == :SUCCEEDED
    end
    
    def failed?(job)
      fetch_job_state(job) == :FAILED
    end

    def cancelled?(job)
      fetch_job_state(job) == :CANCELLED
    end
    
    def active?(job)
      %i[RUNNING PENDING].include?(fetch_job_state(job))
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
      @config['location']
    end

    def service_name
      ActiveStorage::Blob.service.name.to_s
    end

    def default_storage_config
      Rails.application.config.active_storage.service_configurations[service_name]
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

    def fetch_job_state(job)
      @job_state ||= {}
      @job_state[job.name] ||= get_job(job.name).state
    end

    def default_config
      Rails.application.config.transcoder
    end
  end
end
