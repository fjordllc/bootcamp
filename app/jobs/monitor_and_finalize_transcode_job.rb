class MonitorAndFinalizeTranscodeJob < TranscodingJob

  def perform(movie, job_name)
    production_only do
      job = transcoder_client.get_job name: job_name

      case job.state
      when :SUCCEEDED
        file_url = "https://storage.googleapis.com/#{bucket_name}/#{movie.id}/muxed-stream.mp4"

        movie.movie_data.attach(
          io: URI.open(file_url),
          filename: "encoded_#{movie.id}.mp4"
        )
        movie.save

        storage = Google::Cloud::Storage.new
        file = storage.bucket(bucket_name).file("#{movie.id}/muxed-stream.mp4")
        file.delete if file

        Rails.logger.info "Movie #{movie.id} transcoding completed and cleaned up."

      when :FAILED
        Rails.logger.error "Transcoding failed for Movie #{movie.id}"
      when :CANCELLED
        Rails.logger.info "Transcoding job for Movie #{movie.id} was cancelled."
      else
        self.class.set(wait: POLLING_INTERVAL).perform_later(movie, job_name)
      end
    end
  end
end
