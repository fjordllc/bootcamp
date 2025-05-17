# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default

  def perform(movie, job_name = nil)
    Transcoder::Driver.new(movie, job_name).call
  end
end
