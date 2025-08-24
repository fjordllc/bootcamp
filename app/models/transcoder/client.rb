# frozen_string_literal: true

module Transcoder
  class Client
    def initialize(movie = nil, config: nil, bucket_name: nil, project_id: nil, force_video_only: false)
      @movie = movie
      @config = config || default_config
      @bucket_name = bucket_name || default_storage_config['bucket']
      @project_id = project_id || default_storage_config['project']
      @force_video_only = force_video_only

      validate_configuration
    end

    def transcode
      return existing_job if existing_job

      # 処理完了後にAPI::PubSubControllerへPub/Subで通知を送る

      transcoder_service.create_job(
        parent: parent_path,
        job: {
          input_uri:,
          output_uri:,
          config: {
            elementary_streams:,
            mux_streams:,
            pubsub_destination: { topic: pubsub_topic_path }
          },
          labels: { movie_id: @movie.id.to_s }
        }
      )
    rescue Google::Cloud::Error => e
      Rails.logger.error("Failed to create transcoding job for Movie #{@movie.id}: #{e.message}")
      raise
    end

    def get_movie_id(job_name)
      return nil if job_name.blank?

      job = transcoder_service.get_job(name: job_name)
      job&.labels&.[]('movie_id')
    rescue Google::Cloud::Error => e
      Rails.logger.error("Failed to get job #{job_name}: #{e.message}")
      nil
    end

    private

    def existing_job
      transcoder_service.list_jobs(parent: parent_path).find do |job|
        job.labels['movie_id'] == @movie.id.to_s &&
          %w[PENDING RUNNING].include?(job.state)
      end
    rescue Google::Cloud::Error => e
      Rails.logger.error("Failed to list transcoding jobs for Movie #{@movie.id}: #{e.message}")
      nil # リストに失敗した場合は新規作成を許可
    end

    def validate_configuration
      %w[bucket_name project_id location pubsub_topic].each do |key|
        raise ArgumentError, "#{key} is required" if instance_variable_get("@#{key}")&.blank? && @config[key].blank?
      end
    end

    def elementary_streams
      [video_stream_config, (!@force_video_only ? audio_stream_config : nil)].compact
    end

    def video_stream_config
      { key: 'video-stream',
        video_stream: { h264: { height_pixels: @config['video_height'], width_pixels: @config['video_width'], bitrate_bps: @config['video_bitrate'],
                                frame_rate: @config['video_frame_rate'] } } }
    end

    def audio_stream_config
      { key: 'audio-stream', audio_stream: { codec: @config['audio_codec'], bitrate_bps: @config['audio_bitrate'] } }
    end

    def mux_streams
      [{ key: 'muxed-stream', container: @config['container'], elementary_streams: ['video-stream', ('audio-stream' unless @force_video_only)].compact }]
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
      Rails.application.config.active_storage.service_configurations[ActiveStorage::Blob.service.name.to_s] || raise('ActiveStorage service not found')
    end

    def input_uri
      raise ArgumentError, 'Movie and movie_data are required' unless @movie&.movie_data&.key

      "gs://#{@bucket_name}/#{@movie.movie_data.key}"
    end

    def output_uri
      raise ArgumentError, 'Movie ID is required' unless @movie&.id

      "gs://#{@bucket_name}/#{@movie.id}/"
    end

    def parent_path
      "projects/#{@project_id}/locations/#{location}"
    end

    def pubsub_topic_path
      "projects/#{@project_id}/topics/#{@config['pubsub_topic']}"
    end

    def default_config
      Rails.application.config.transcoder
    end
  end
end
