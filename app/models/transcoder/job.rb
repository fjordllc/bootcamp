# frozen_string_literal: true

module Transcoder
  class Job
    POLLING_INTERVAL = 60.seconds

    def initialize(movie, name = nil)
      @movie = movie
      @client = Transcoder::Client.new(@movie)
      @name = name || @client.create_job
    end

    def call
      # return unless Rails.env.production?

      handle_state
    end

    private

    def state
      @client.fetch_job_state(@name)
    end

    def schedule_polling
      TranscodeJob.set(wait: POLLING_INTERVAL).perform_later(@movie, @name)
    end

    def handle_state
      handlers.fetch(state) { method(:unknown_state) }.call
    end

    def handlers
      {
        SUCCEEDED: -> { Transcoder::File.new(@movie).attach_and_cleanup },
        FAILED: -> { Rails.logger.error "Transcoding failed for Movie #{@movie.id}" },
        CANCELLED: -> { Rails.logger.error "Transcoding job for Movie #{@movie.id} was cancelled." },
        RUNNING: -> { schedule_polling },
        PENDING: -> { schedule_polling }
      }
    end

    def unknown_state
      Rails.logger.warn "Unknown transcoder job state for Movie #{@movie.id}. No further action taken."
    end
  end
end
