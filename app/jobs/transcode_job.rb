# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  MAX_RETRIES = 5
  BASE_WAIT   = 30.seconds
  MAX_WAIT    = 5.minutes
  JITTER_RATE = 0.1

  queue_as :default

  def perform(movie, force_video_only: false)
    return unless Rails.application.config.transcoder['enabled']

    Transcoder::Client.new(movie, force_video_only:).transcode
  rescue Google::Cloud::Error => e
    handle_transcode_error(e, movie)
  end

  private

  def handle_transcode_error(error, movie)
    if retryable?(error) && executions < MAX_RETRIES
      log_retry(movie, error)
      retry_job(wait: calculate_retry_wait(executions))
      return
    end

    log_failure(movie, error)
    notify_failure(movie, error)
  end

  def retryable?(error)
    code_str = error.respond_to?(:code) ? error.code.to_s.downcase : ''
    %w[429 503 8 14 resource_exhausted unavailable].include?(code_str)
  end

  def log_retry(movie, error)
    Rails.logger.warn(
      "Retrying Transcoding for Movie #{movie.id} " \
      "(code=#{error.code}, attempt=#{executions + 1})"
    )
  end

  def log_failure(movie, error)
    code = error.respond_to?(:code) ? error.code : 'n/a'
    Rails.logger.error(
      "Transcoding failed for Movie #{movie.id}: #{error.message} (code=#{code})"
    )
  end

  def notify_failure(movie, error)
    # 捕まえた例外は Rollbar に自動送信されないため、明示的に通知する。
    # movieの作成は既に完了しているため、ジョブ失敗でユーザー体験を損なわないよう例外は再送出しない
    Rollbar.error(error, movie_id: movie.id) if defined?(Rollbar)
  end

  def calculate_retry_wait(executions)
    base     = BASE_WAIT * (2**executions)
    wait_for = [base, MAX_WAIT].min
    jitter   = (wait_for * JITTER_RATE).to_i
    wait_for + rand(-jitter..jitter)
  end
end
