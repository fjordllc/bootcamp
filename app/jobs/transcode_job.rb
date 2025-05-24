# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default

  POLLING_INTERVAL = 60.seconds

  def perform(movie, job_name = nil)
    return unless Rails.application.config.transcoder['enable']

    @movie = movie
    @api_client = Transcoder::APIClient.new(@movie)
    @job_name = job_name || @api_client.create_transcoding_job
    job_state = @api_client.job_state(@job_name)
    case job_state
    when :succeeded then attach_transcoded_movie
    when :failed    then log_state(:failed)
    when :cancelled then log_state(:cancelled)
    when :active    then schedule_polling
    else
      log_state(:unknown)
    end
  end

  private

  def attach_transcoded_movie
    file = Transcoder::TranscodedMovieFile.new(@movie)
    @movie.movie_data.attach(io: file.data, filename: "#{@movie.id}.mp4")
    file.cleanup
  end

  def log_state(state)
    level = %i[failed cancelled].include?(state) ? :error : :warn
    message = case state
              when :failed
                "Transcoding failed for Movie #{@movie.id}"
              when :cancelled
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
