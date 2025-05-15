# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default
  POLLING_INTERVAL = 60.seconds

  def perform(movie, job_name = nil)
    return unless Rails.env.production?

    client = Transcoder::Client.new(movie)

    if job_name.nil?
      job = client.start
      self.class.set(wait: POLLING_INTERVAL).perform_later(movie, job.name)
      return
    end

    job = client.fetch(job_name)

    case job.state
    when :SUCCEEDED
      Transcoder::Attacher.new(movie).perform
      Rails.logger.info "Movie #{movie.id} transcoding completed."
    when :FAILED
      Rails.logger.error "Transcoding failed for Movie #{movie.id}"
    when :CANCELLED
      Rails.logger.info "Transcoding job for Movie #{movie.id} was cancelled."
    else
      self.class.set(wait: POLLING_INTERVAL).perform_later(movie, job_name)
    end
  end
end
