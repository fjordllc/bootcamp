# frozen_string_literal: true

class MonitorAndFinalizeTranscodeJob < TranscodingJob
  def perform(movie, job_name)
    production_only do
      job = transcoder_client.get_job name: job_name

      case job.state
      when :SUCCEEDED
        handle_succeeded_job(movie)
      when :FAILED
        handle_failed_job(movie)
      when :CANCELLED
        handle_cancelled_job(movie)
      else
        poll_transcoding_job(movie, job_name)
      end
    end
  end

  private

  def handle_succeeded_job(movie)
    gcs_path = "#{movie.id}/muxed-stream.mp4"
    attach_movie_data(movie, gcs_path)
    cleanup_file(gcs_path)
    Rails.logger.info "Movie #{movie.id} transcoding completed and cleaned up."
  end

  def handle_failed_job(movie)
    Rails.logger.error "Transcoding failed for Movie #{movie.id}"
  end

  def handle_cancelled_job(movie)
    Rails.logger.info "Transcoding job for Movie #{movie.id} was cancelled."
  end

  def poll_transcoding_job(movie, job_name)
    self.class.set(wait: POLLING_INTERVAL).perform_later(movie, job_name)
  end

  def attach_movie_data(movie, gcs_path)
    file = storage.bucket(bucket_name).file(gcs_path)
    io = StringIO.new(file.download.string)

    movie.movie_data.attach(
      io:,
      filename: "encoded_#{movie.id}.mp4"
    )
    movie.save
  end

  def cleanup_file(gcs_path)
    file = storage.bucket(bucket_name).file(gcs_path.to_s)
    file&.delete
  end

  def storage
    @storage ||= Google::Cloud::Storage.new
  end
end
