# frozen_string_literal: true

class ProcessTranscodingNotification
  include Interactor

  def call
    message = parse_pubsub_message(context.body)
    unless message
      context.fail!(error: 'Invalid message format')
      return
    end

    job_name = message[:job_name]
    job_state = message[:job_state]
    error = message[:error]

    movie = find_movie(job_name)
    context.fail!(error: "Movie not found for job_name: #{job_name}") unless movie

    handle_job_state(movie, job_name, job_state, error)
  rescue StandardError => e
    Rails.logger.error("Unhandled error in ProcessTranscodingNotification: #{e.message}")
    context.fail!(error: e.message)
  end

  private

  def parse_pubsub_message(body)
    message = JSON.parse(body)
    encoded_data = message.dig('message', 'data')
    return nil unless encoded_data

    data = JSON.parse(Base64.decode64(encoded_data))

    {
      job_name: data.dig('job', 'name'),
      job_state: data.dig('job', 'state'),
      error: data.dig('job', 'error')
    }
  rescue JSON::ParserError, ArgumentError => e
    Rails.logger.error("Failed to parse Pub/Sub message: #{e.message}")
    nil
  end

  def find_movie(job_name)
    movie_id = Transcoder::Client.new.get_movie_id(job_name)
    Movie.find_by(id: movie_id)
  rescue Google::Cloud::Error => e
    Rails.logger.error("Failed to get movie_id for job #{job_name}: #{e.message}")
    nil
  end

  def handle_job_state(movie, job_name, job_state, error)
    case job_state
    when 'SUCCEEDED'
      attach_transcoded_file(movie)
    when 'FAILED', 'CANCELLED'
      if audio_missing_error?(error)
        Rails.logger.warn("Audio missing error detected for Movie #{movie.id}. Retrying without audio.")
        TranscodeJob.perform_later(movie, include_audio: false)
      else
        Rails.logger.error("Transcoding job #{job_name} for Movie #{movie.id} failed or cancelled.")
      end
    else
      Rails.logger.warn("Unknown job state: #{job_state} for Movie #{movie.id}")
    end
  end

  def attach_transcoded_file(movie)
    transcoded_movie = Transcoder::Movie.new(movie)
    movie.movie_data.attach(io: transcoded_movie.data, filename: "#{movie.id}.mp4")
    movie.save!
    Rails.logger.info("Successfully attached transcoded movie for Movie #{movie.id}")
  rescue StandardError => e
    Rails.logger.error("Failed to attach transcoded movie for Movie #{movie.id}: #{e.message}")
    raise
  ensure
    transcoded_movie.cleanup if transcoded_movie.respond_to?(:cleanup)
  end

  def audio_missing_error?(error)
    return false if error.blank?

    details = error['details'] || []
    details.any? do |detail|
      field_violations = detail['fieldViolations'] || []
      field_violations.any? { |fv| fv['description'] == 'AudioMissing' }
    end
  rescue StandardError => e
    Rails.logger.error("Failed to check audio missing error: #{e.message}")
    false
  end
end
