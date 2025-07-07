# frozen_string_literal: true

module Transcoder
  class Movie
    def initialize(movie, bucket_name: nil, path: nil)
      @movie = movie
      @bucket_name = bucket_name || default_bucket_name
      @path = path || default_path
    end

    def data
      StringIO.new(file.download.string)
    end

    def cleanup
      file&.delete
    end

    private

    def file
      @file ||= storage.bucket(@bucket_name).file(@path)
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
