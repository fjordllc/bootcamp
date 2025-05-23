# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default

  POLLING_INTERVAL = 60.seconds

  def perform(movie, job_name = nil)
    @movie = movie
    @api_client = Transcoder::ApiClient.new(@movie)
    @job_name = job_name || @api_client.create_job

    return unless Rails.application.config.transcoder['enable']

    case job_state
    when :succeeded then handle_success
    when :failed    then log_state("failed")
    when :cancelled then log_state("cancelled")
    when :active    then schedule_polling
    else
      log_state("unknown")
    end
  end

  private

  def job_state
    return :succeeded if @api_client.succeeded?(@job_name)
    return :failed    if @api_client.failed?(@job_name)
    return :cancelled if @api_client.cancelled?(@job_name)
    return :active    if @api_client.active?(@job_name)
    :unknown
  end

  def handle_success
    file = Transcoder::TranscodedMovieFile.new(@movie)
    @movie.movie_data.attach(io: file.data, filename: "#{@movie.id}.mp4")
    file.cleanup
  end

  def log_state(state)
    level = %w[failed cancelled].include?(state) ? :error : :warn
    message = case state
              when "failed"
                "Transcoding failed for Movie #{@movie.id}"
              when "cancelled"
                "Transcoding job for Movie #{@movie.id} was cancelled."
              else
                "Unknown transcoder job state for Movie #{@movie.id}. No further action taken."
              end

    Rails.logger.send(level, message)
  end

  def schedule_polling
    TranscodeJob.set(wait: POLLING_INTERVAL).perform_later(@movie, @job_name)
  end
end
