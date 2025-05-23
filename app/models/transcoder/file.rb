# frozen_string_literal: true

module Transcoder
  class File
    def initialize(movie, bucket_name: nil)
      @movie = movie
      @bucket_name = bucket_name || default_bucket_name
    end

    def transcoded_data
      transcoded_file = storage.bucket(bucket_name).file(transcoded_video_path)
      StringIO.new(transcoded_file.download.string)
    end

    private

    def cleanup(file)
      file&.delete
    end

    def storage
      Google::Cloud::Storage.new
    end

    def default_bucket_name
      service_name = ActiveStorage::Blob.service.name.to_s
      Rails.application.config.active_storage.service_configurations[service_name]['bucket']
    end

    def transcoded_video_path
      "#{@movie.id}/muxed-stream.mp4"
    end
  end
end
