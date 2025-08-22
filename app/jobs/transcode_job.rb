# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default

  def perform(movie, force_video_only: false)
    return unless Rails.application.config.transcoder['enabled']

    client = Transcoder::Client.new(movie, force_video_only:)
    client.transcode
  rescue Google::Cloud::Error => e
    code_str = e.respond_to?(:code) ? e.code.to_s.downcase : ''
    retryable_codes = %w[429 503 8 14 resource_exhausted unavailable]
    if retryable_codes.include?(code_str)
      if executions < 5
        Rails.logger.warn("Retrying Transcoding for Movie #{movie.id} (code=#{e.code}, attempt=#{executions + 1})")
        retry_job(wait: 30.seconds)
        return
      else
        Rails.logger.error("Exceeded max retries for Movie #{movie.id} (code=#{e.code})")
      end
    end
    Rails.logger.error("Transcoding failed for Movie #{movie.id}: #{e.message} (code=#{e.respond_to?(:code) ? e.code : 'n/a'})")
    raise
  end
end
