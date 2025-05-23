# frozen_string_literal: true

module Transcoder
  class Job
    POLLING_INTERVAL = 60.seconds

    def initialize(movie, name = nil)
      @movie = movie
      @api_client = Transcoder::ApiClient.new(@movie)
      @name = name || @api_client.create_job
    end

    def call(&block)
      return unless Rails.application.config.transcoder['enable']

      @block = block
      handle_state
    end

    private

    def state
      @api_client.fetch_job_state(@name)
    end

    def schedule_polling
      TranscodeJob.set(wait: POLLING_INTERVAL).perform_later(@movie, @name)
    end

    def handle_state
      handlers[state_category].call
    end

    def handlers
      {
        succeeded: -> { handle_success },
        failed:    -> { log_failure },
        cancelled: -> { log_cancel },
        active:    -> { schedule_polling },
        unknown:   -> { log_unknown }
      }
    end

    def state_category
      return :succeeded if @api_client.succeeded?(@name)
      return :failed    if @api_client.failed?(@name)
      return :cancelled if @api_client.cancelled?(@name)
      return :active    if @api_client.active?(@name)
      :unknown
    end

    def handle_success
      transcoded_data = Transcoder::MovieFile.new(@movie).transcoded_data
      @block.call(transcoded_data) if @block
    end

    def log_failure
      Rails.logger.error "Transcoding failed for Movie #{@movie.id}"
    end

    def log_cancel
      Rails.logger.error "Transcoding job for Movie #{@movie.id} was cancelled."
    end

    def log_unknown
      Rails.logger.warn "Unknown transcoder job state for Movie #{@movie.id}. No further action taken."
    end

  end
end
