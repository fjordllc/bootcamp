# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default

  def perform(movie, job_name = nil)
  transcode_job = Transcoder::Job.new(movie, job_name)
  transcode_job.call do |transcoded_data|
    @movie.movie_data.attach(io: transcoded_data filename: "#{movie.id}.mp4")
    @movie.save
  end
end
