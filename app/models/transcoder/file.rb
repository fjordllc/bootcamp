# frozen_string_literal: true

module Transcoder
  class File
    def initialize(movie)
      @movie = movie
    end

    def attach_and_cleanup
      file = storage.bucket(bucket_name).file(transcoded_video_path)
      attach(file)
      cleanup(file)
    end

    private

    def attach(file)
      io = StringIO.new(file.download.string)
      @movie.movie_data.attach(io:, filename: "#{@movie.id}.mp4")
      @movie.save
    end

    def cleanup(file)
      file&.delete
    end

    def storage
      Google::Cloud::Storage.new
    end

    def bucket_name
      service_name = ActiveStorage::Blob.service.name.to_s
      Rails.application.config.active_storage.service_configurations[service_name]['bucket']
    end

    def transcoded_video_path
      "#{@movie.id}/muxed-stream.mp4"
    end
  end
end
