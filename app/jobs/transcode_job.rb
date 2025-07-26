# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default

  def perform(movie)
    return unless Rails.application.config.transcoder['enable']

    client = Transcoder::Client.new(movie)
    client.transcode
  rescue Google::Cloud::Error => e
    Rails.logger.error("Transcoding failed for Movie #{movie.id}: #{e.message}")
    # API エラーの場合は再試行しない
    raise e unless e.respond_to?(:code) && [429, 503].include?(e.code)

    retry_job(wait: 30.seconds)
  rescue StandardError => e
    Rails.logger.error("Unexpected error during transcoding for Movie #{movie.id}: #{e.message}")
    raise
  end
end
