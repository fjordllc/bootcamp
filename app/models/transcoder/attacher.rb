# frozen_string_literal: true

module Transcoder
  class Attacher
    def initialize(movie)
      service_name = ActiveStorage::Blob.service.name.to_s
      @movie = movie
      @transcoded_video_path = "#{movie.id}/muxed-stream.mp4"
      @storage = Google::Cloud::Storage.new
      @bucket_name = Rails.application.config.active_storage.service_configurations[service_name]['bucket']
    end

    def perform
      file = storage.bucket(bucket_name).file(transcoded_video_path)
      attach(file)
      delete(file)
    end

    private

    attr_reader :movie, :transcoded_video_path, :storage, :bucket_name

    def attach(file)
      io = StringIO.new(file.download.string)
      movie.movie_data.attach(io:, filename: "#{movie.id}.mp4")
      movie.save
    end

    def delete(file)
      file&.delete
    end
  end
end
