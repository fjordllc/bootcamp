# frozen_string_literal: true

class BulkEmbeddingJob < ApplicationJob
  include SmartSearch::ErrorHandler

  queue_as :default

  def perform(model_name: nil, force_regenerate: false, parallel: false)
    # Check if credentials are available
    generator = SmartSearch::EmbeddingGenerator.new
    unless generator.instance_variable_get(:@credentials_available)
      Rails.logger.info "Bulk embedding job skipped - Google Cloud credentials not available"
      return
    end
    
    if model_name
      process_model(model_name, force_regenerate)
    elsif parallel
      process_models_parallel(force_regenerate)
    else
      SmartSearch::Configuration::EMBEDDING_MODELS.each do |model|
        process_model(model, force_regenerate)
      end
    end
  end

  private

  def process_models_parallel(force_regenerate)
    require 'concurrent'

    # 並列処理時はAPI制限を考慮してスレッド数を制限
    max_threads = [SmartSearch::Configuration::EMBEDDING_MODELS.size, 3].min # 最大3スレッドに制限

    thread_pool = Concurrent::ThreadPoolExecutor.new(
      min_threads: 1,
      max_threads:,
      max_queue: 0,
      fallback_policy: :caller_runs
    )

    message = "Starting parallel processing with #{max_threads} threads for #{SmartSearch::Configuration::EMBEDDING_MODELS.size} models"
    log_info message

    futures = SmartSearch::Configuration::EMBEDDING_MODELS.map do |model_name|
      Concurrent::Future.execute(executor: thread_pool) do
        # 並列処理フラグを設定
        Thread.current[:parallel_processing] = true
        process_model(model_name, force_regenerate)
      end
    end

    # 全てのタスクの完了を待つ
    futures.each(&:wait!)

    # エラーをチェック
    errors = futures.select(&:rejected?).map(&:reason)
    unless errors.empty?
      message = "Some models failed to process: #{errors.map(&:message).join(', ')}"
      log_error message
      raise errors.first
    end

    message = '✅ All models processed successfully in parallel'
    log_info message
  ensure
    thread_pool&.shutdown
    thread_pool&.wait_for_termination(30)
  end

  def process_model(model_name, force_regenerate)
    model_class = model_name.constantize

    scope = force_regenerate ? model_class.all : model_class.where(embedding: nil)
    total_count = scope.count

    message = "Processing #{total_count} #{model_name} records for embedding generation"
    log_info message

    processed_count = 0
    successful_count = 0
    failed_batches = 0

    scope.find_in_batches(batch_size: SmartSearch::Configuration::BATCH_SIZE) do |batch|
      result = SmartSearch::BatchProcessor.new.process_batch(batch, model_name)
      processed_count += batch.size

      if result[:success]
        successful_count += result[:processed]
      else
        failed_batches += 1

        # API制限エラーの場合は処理を停止
        if result[:error_type] == :token_limit
          error_msg = "🛑 Stopping #{model_name} processing due to token limit. Processed: #{successful_count}/#{total_count}"
          log_error error_msg
          break
        end
      end

      # 動的な進捗ログ間隔：小さなデータセットはより頻繁に、大きなデータセットは適度に
      log_interval = calculate_log_interval(total_count)

      log_progress(processed_count, successful_count, total_count, model_name) if should_log_progress?(processed_count, total_count, log_interval)

      # 並列処理時はより長い待機時間でAPI制限を回避
      sleep_time = Thread.current[:parallel_processing] ? 0.1 : 0.05
      sleep(sleep_time)
    end

    # 最終結果の報告
    final_message = if failed_batches.positive?
                      "⚠️ Completed #{model_name} with issues: #{successful_count}/#{total_count} records saved, #{failed_batches} batches failed"
                    else
                      "✅ Completed embedding generation for #{model_name}: #{successful_count}/#{total_count} records"
                    end

    log_info final_message
  rescue StandardError => e
    message = "Critical error processing #{model_name} embeddings: #{e.message}"
    log_error message
    raise e
  end

  def calculate_log_interval(total_count)
    case total_count
    when 0..100 then 1    # 40レコードごと
    when 101..500 then 2  # 80レコードごと
    when 501..1000 then 3 # 120レコードごと
    else 5                # 200レコードごと
    end
  end

  def should_log_progress?(processed_count, total_count, log_interval)
    ((processed_count / SmartSearch::Configuration::BATCH_SIZE) % log_interval).zero? || processed_count == total_count
  end

  def log_progress(processed_count, successful_count, total_count, model_name)
    percentage = ((processed_count.to_f / total_count) * 100).round(1)
    saved_percentage = ((successful_count.to_f / total_count) * 100).round(1)
    message = "Progress: #{processed_count}/#{total_count} #{model_name} records processed (#{percentage}%), #{successful_count} saved (#{saved_percentage}%)"
    log_info message
  end
end
