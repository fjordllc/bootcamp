# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  MAX_RETRIES = 5
  BASE_WAIT = 30.seconds
  MAX_WAIT = 5.minutes
  JITTER_RATE = 0.1

  queue_as :default

  def perform(movie, force_video_only: false)
    return unless Rails.application.config.transcoder['enabled']

    client = Transcoder::Client.new(movie, force_video_only:)
    client.transcode
  rescue Google::Cloud::Error => e
    code_str = e.respond_to?(:code) ? e.code.to_s.downcase : ''
    retryable_codes = %w[429 503 8 14 resource_exhausted unavailable]
    if retryable_codes.include?(code_str)
      if executions < MAX_RETRIES
        Rails.logger.warn("Retrying Transcoding for Movie #{movie.id} (code=#{e.code}, attempt=#{executions + 1})")
        retry_job(wait: calculate_retry_wait(executions))
        return
      else
        Rails.logger.error("Exceeded max retries for Movie #{movie.id} (code=#{e.code})")
      end
    end
    Rails.logger.error("Transcoding failed for Movie #{movie.id}: #{e.message} (code=#{e.respond_to?(:code) ? e.code : 'n/a'})")
    # 捕まえた例外は Rollbar に自動送信されないため、明示的に通知する。
    # エンコードジョブの失敗でアプリケーション全体を停止させないため、例外は再送出しない
    Rollbar.error(e, movie_id: movie.id) if defined?(Rollbar)
    nil
  end

  private

  def calculate_retry_wait(executions)
    base = BASE_WAIT * (2**executions)
    wait_for = [base, MAX_WAIT].min
    jitter = (wait_for * JITTER_RATE).to_i
    wait_for + rand(-jitter..jitter)
  end
end
