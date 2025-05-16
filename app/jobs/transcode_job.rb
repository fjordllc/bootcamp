# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default
  POLLING_INTERVAL = 60.seconds

  def perform(movie, job_name = nil)
    return unless Rails.env.production?

    client = Transcoder::Client.new(movie)

    if job_name.nil?
      job = client.create_job
      schedule_polling_job(movie, job.name)
      return
    end

    state = client.fetch_job_state(job_name)
    handlers = job_state_handlers(movie)

    handlers[state]&.call || schedule_polling_job(movie, job_name)
  end

  private

  def schedule_polling_job(movie, job_name)
    self.class.set(wait: POLLING_INTERVAL).perform_later(movie, job_name)
  end

  def job_state_handlers(movie)
    {
      SUCCEEDED: -> { Transcoder::Attacher.new(movie).perform },
      FAILED: -> { Rails.logger.error "Transcoding failed for Movie #{movie.id}" },
      CANCELLED: -> { Rails.logger.info "Transcoding job for Movie #{movie.id} was cancelled." }
    }
  end
end
