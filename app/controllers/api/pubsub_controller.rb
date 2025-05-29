# frozen_string_literal: true

class API::PubsubController < API::BaseController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login_for_api

  def create
    message = parse_pubsub_message(request.body.read)
    job_name = message[:job_name]
    job_state = message[:job_state]

    movie = find_movie(job_name)

    if movie
      handle_job_state(movie, job_name, job_state)
    else
      Rails.logger.error("Movie not found for job_name: #{job_name}")
    end

    head :ok
  end

  private

  def parse_pubsub_message(body)
    message = JSON.parse(body)
    data = JSON.parse(Base64.decode64(message['message']['data']))

    {
      job_name: data.dig('job', 'name'),
      job_state: data.dig('job', 'state')
    }
  end

  def find_movie(job_name)
    movie_id = Transcoder::Client.new.get_movie_id(job_name)
    Movie.find_by(id: movie_id)
  end

  def handle_job_state(movie, job_name, job_state)
    case job_state
    when 'SUCCEEDED'
      attach_transcoded_file(movie)
    when 'FAILED', 'CANCELLED'
      Rails.logger.error("Transcoding job #{job_name} for Movie #{movie.id} failed or cancelled.")
    else
      Rails.logger.warn("Unknown job state: #{job_state} for Movie #{movie.id}")
    end
  end

  def attach_transcoded_file(movie)
    file = Transcoder::Movie.new(movie)
    movie.movie_data.attach(io: file.data, filename: "#{movie.id}.mp4")
    movie.save
    file.cleanup
  end
end
