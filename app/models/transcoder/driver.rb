# frozen_string_literal: true

module Transcoder
  class Driver
    POLLING_INTERVAL = 60.seconds

    def initialize(movie, job_name = nil)
      @movie = movie
      @job_name = job_name
    end

    def call
      # return unless Rails.env.production?

      if job_name.nil?
        job = client.create_job
        schedule_polling_job(job.name)
        return
      end

      state = client.fetch_job_state(job_name)
      handler = handlers[state]

      if handler
        handler.call
      else
        Rails.logger.warn "Unknown transcoder job state: #{state} for Movie #{movie.id}. No further action taken."
      end
    end

    private

    attr_reader :movie, :job_name

    def client
      @client ||= Transcoder::Client.new(movie)
    end

    def schedule_polling_job(job_name)
      TranscodeJob.set(wait: POLLING_INTERVAL).perform_later(movie, job_name)
    end

    def handlers
      {
        SUCCEEDED: -> { Transcoder::Attacher.new(movie).perform },
        FAILED: -> { Rails.logger.error "Transcoding failed for Movie #{movie.id}" },
        CANCELLED: -> { Rails.logger.error "Transcoding job for Movie #{movie.id} was cancelled." },
        RUNNING: -> { schedule_polling_job(job_name) },
        PENDING: -> { schedule_polling_job(job_name) }
      }
    end
  end
end
