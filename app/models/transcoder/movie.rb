# frozen_string_literal: true

module Transcoder
  class Movie
    def initialize(movie, bucket_name: nil, path: nil)
      @movie = movie
      @bucket_name = bucket_name || default_bucket_name
      @path = path || default_path
      @tempfile = nil
    end

    def data
      raise 'Transcoded file not found' unless file&.exists?

      @tempfile = Tempfile.new([@movie.id.to_s, '.mp4'], binmode: true)

      file.download @tempfile.path

      @tempfile.rewind
      @tempfile
    rescue Google::Cloud::Storage::FileVerificationError => e
      Rails.logger.error "File verification failed: #{e.message}"
      raise
    rescue Google::Cloud::Error => e
      Rails.logger.error "Failed to download transcoded file: #{e.message}"
      raise
    end

    def cleanup
      cleanup_gcs
      cleanup_tempfile
    end

    private

    def cleanup_gcs
      return unless file&.exists?

      file.delete
    rescue Google::Cloud::Storage::FileVerificationError, Google::Cloud::Error => e
      # クリーンアップ失敗は処理結果に影響させない
      Rails.logger.warn "Cleanup skipped (GCS): #{e.class}: #{e.message}"
    end

    def cleanup_tempfile
      return unless @tempfile

      @tempfile.close!
      @tempfile = nil
    rescue StandardError => e
      # クリーンアップ失敗は処理結果に影響させない
      Rails.logger.warn "Cleanup skipped (Tempfile): #{e.class}: #{e.message}"
    end

    def file
      @file ||= bucket.file(@path)
    end

    def bucket
      @bucket ||= begin
        bucket_obj = storage.bucket(@bucket_name)
        raise "Bucket not found or inaccessible: #{@bucket_name}" unless bucket_obj

        bucket_obj
      end
    end

    def storage
      Google::Cloud::Storage.new
    end

    def default_bucket_name
      service_name = ActiveStorage::Blob.service.name.to_s
      config = Rails.application.config.active_storage.service_configurations[service_name]
      raise "ActiveStorage service configuration not found: #{service_name}" unless config
      raise "Bucket not configured for service: #{service_name}" unless config['bucket']

      config['bucket']
    end

    def default_path
      "#{@movie.id}/muxed-stream.mp4"
    end
  end
end
