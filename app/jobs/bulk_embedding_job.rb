# frozen_string_literal: true

class BulkEmbeddingJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 40
  # Embedding対象のモデル（検索結果には表示されないものも含む）
  EMBEDDING_MODELS = %w[Practice Report Product Page Question Announcement Event RegularEvent FAQ SubmissionAnswer].freeze
  # Smart検索で実際に検索結果に表示されるモデル
  SEARCHABLE_MODELS = %w[Practice Report Product Page Question Announcement Event RegularEvent FAQ].freeze

  def self.embedding_logger
    @embedding_logger ||= Logger.new(Rails.root.join('log/embedding.log')).tap do |logger|
      logger.level = Logger::INFO
      logger.formatter = proc do |severity, datetime, _progname, msg|
        "[#{datetime.strftime('%H:%M:%S')}] #{severity}: #{msg}\n"
      end
    end
  end

  def perform(model_name: nil, force_regenerate: false, parallel: false)
    if model_name
      process_model(model_name, force_regenerate)
    elsif parallel
      process_models_parallel(force_regenerate)
    else
      EMBEDDING_MODELS.each do |model|
        process_model(model, force_regenerate)
      end
    end
  end

  private

  def process_models_parallel(force_regenerate)
    require 'concurrent'

    # 並列処理時はAPI制限を考慮してスレッド数を制限
    max_threads = [EMBEDDING_MODELS.size, 3].min # 最大3スレッドに制限

    thread_pool = Concurrent::ThreadPoolExecutor.new(
      min_threads: 1,
      max_threads:,
      max_queue: 0,
      fallback_policy: :caller_runs
    )

    message = "Starting parallel processing with #{max_threads} threads for #{EMBEDDING_MODELS.size} models"
    Rails.logger.info message
    self.class.embedding_logger.info message

    futures = EMBEDDING_MODELS.map do |model_name|
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
      message = "❌ Some models failed to process: #{errors.map(&:message).join(', ')}"
      Rails.logger.error message
      self.class.embedding_logger.error message
      raise errors.first
    end

    message = '✅ All models processed successfully in parallel'
    Rails.logger.info message
    self.class.embedding_logger.info message
  ensure
    thread_pool&.shutdown
    thread_pool&.wait_for_termination(30)
  end

  def process_model(model_name, force_regenerate)
    model_class = model_name.constantize

    scope = force_regenerate ? model_class.all : model_class.where(embedding: nil)
    total_count = scope.count

    message = "Processing #{total_count} #{model_name} records for embedding generation"
    Rails.logger.info message
    self.class.embedding_logger.info message

    processed_count = 0
    successful_count = 0
    failed_batches = 0

    scope.find_in_batches(batch_size: BATCH_SIZE) do |batch|
      result = process_batch(batch, model_name)
      processed_count += batch.size

      if result[:success]
        successful_count += result[:processed]
      else
        failed_batches += 1

        # API制限エラーの場合は処理を停止
        if result[:error_type] == :token_limit
          error_msg = "🛑 Stopping #{model_name} processing due to token limit. Processed: #{successful_count}/#{total_count}"
          Rails.logger.error error_msg
          self.class.embedding_logger.error error_msg
          break
        end
      end

      # 動的な進捗ログ間隔：小さなデータセットはより頻繁に、大きなデータセットは適度に
      log_interval = case total_count
                     when 0..100 then 1    # 40レコードごと
                     when 101..500 then 2  # 80レコードごと
                     when 501..1000 then 3 # 120レコードごと
                     else 5                # 200レコードごと
                     end

      if ((processed_count / BATCH_SIZE) % log_interval).zero? || processed_count == total_count
        percentage = ((processed_count.to_f / total_count) * 100).round(1)
        saved_percentage = ((successful_count.to_f / total_count) * 100).round(1)
        message = "Progress: #{processed_count}/#{total_count} #{model_name} records processed (#{percentage}%), #{successful_count} saved (#{saved_percentage}%)"
        Rails.logger.info message
        self.class.embedding_logger.info message
      end

      # 並列処理時はより長い待機時間でAPI制限を回避
      sleep_time = Thread.current[:parallel_processing] ? 0.1 : 0.05
      sleep(sleep_time)
    end

    # 最終結果の報告
    final_message = if failed_batches > 0
                      "⚠️ Completed #{model_name} with issues: #{successful_count}/#{total_count} records saved, #{failed_batches} batches failed"
                    else
                      "✅ Completed embedding generation for #{model_name}: #{successful_count}/#{total_count} records"
                    end

    Rails.logger.info final_message
    self.class.embedding_logger.info final_message
  rescue StandardError => e
    message = "❌ Critical error processing #{model_name} embeddings: #{e.message}"
    Rails.logger.error message
    self.class.embedding_logger.error message
    raise e
  end

  def process_batch(records, model_name)
    text_contents = records.map { |record| extract_text_content(record) }.compact
    return { success: true, processed: 0, message: 'No text content to process' } if text_contents.empty?

    generator = SmartSearch::EmbeddingGenerator.new

    # トークン数をチェックして必要に応じてバッチサイズを調整
    estimated_tokens = generator.estimate_batch_token_count(text_contents)
    if estimated_tokens > SmartSearch::EmbeddingGenerator::MAX_TOKENS
      # バッチサイズを動的に調整
      optimal_size = generator.calculate_optimal_batch_size(text_contents)

      if optimal_size == 0
        token_error_msg = "❌ Cannot process #{model_name} batch: Even single record exceeds token limit (#{estimated_tokens} tokens)"
        Rails.logger.error token_error_msg
        self.class.embedding_logger.error token_error_msg
        return { success: false, processed: 0, message: token_error_msg, error_type: :token_limit }
      elsif optimal_size < records.length
        # バッチを分割して処理
        warning_msg = "⚠️ Batch too large (#{estimated_tokens} tokens), splitting #{records.length} → #{optimal_size} records for #{model_name}"
        Rails.logger.warn warning_msg
        self.class.embedding_logger.warn warning_msg

        # 最適サイズでバッチを分割
        smaller_records = records[0...optimal_size]
        smaller_text_contents = text_contents[0...optimal_size]

        # 残りのレコードも処理
        remaining_records = records[optimal_size..-1]
        remaining_result = process_batch(remaining_records, model_name) if remaining_records.any?

        # 小さなバッチを処理
        current_result = process_smaller_batch(smaller_records, smaller_text_contents, model_name, generator)

        # 結果をマージ
        total_processed = current_result[:processed] + (remaining_result ? remaining_result[:processed] : 0)
        combined_success = current_result[:success] && (remaining_result ? remaining_result[:success] : true)

        combined_msg = "Split batch processed: #{total_processed}/#{records.length} #{model_name} records"
        return { success: combined_success, processed: total_processed, message: combined_msg }
      end
    end

    # 通常の処理（トークン制限内）
    process_smaller_batch(records, text_contents, model_name, generator)
  end

  def process_smaller_batch(records, text_contents, model_name, generator)
    embeddings = generator.generate_embeddings_batch(text_contents)

    if embeddings.empty?
      error_msg = "No embeddings generated for #{records.length} #{model_name} records"
      Rails.logger.error error_msg
      self.class.embedding_logger.error error_msg
      return { success: false, processed: 0, message: error_msg }
    end

    # 実際の保存処理と成功カウント
    saved_count = 0
    records.each_with_index do |record, index|
      next if index >= embeddings.length || embeddings[index].nil?

      begin
        # Vector型として保存するために配列を文字列形式に変換
        vector_string = "[#{embeddings[index].join(',')}]"
        # SQL安全な方法で更新（updated_atも明示的に更新）
        result = record.class.where(id: record.id).update_all(
          embedding: vector_string,
          updated_at: Time.current
        )
        saved_count += 1 if result == 1
      rescue StandardError => e
        Rails.logger.error "Failed to save embedding for #{model_name} ID #{record.id}: #{e.message}"
        self.class.embedding_logger.error "Failed to save embedding for #{model_name} ID #{record.id}: #{e.message}"
      end
    end

    success_msg = "Successfully saved #{saved_count}/#{records.length} embeddings for #{model_name}"
    Rails.logger.info success_msg
    self.class.embedding_logger.info success_msg

    { success: true, processed: saved_count, message: success_msg }
  rescue Google::Cloud::InvalidArgumentError => e
    # API制限エラーの特別処理
    if e.message.include?('token count')
      token_error_msg = "❌ API Token Limit Error for #{model_name}: #{e.message}"
      Rails.logger.error token_error_msg
      self.class.embedding_logger.error token_error_msg
      { success: false, processed: 0, message: token_error_msg, error_type: :token_limit }
    else
      api_error_msg = "❌ API Error for #{model_name}: #{e.message}"
      Rails.logger.error api_error_msg
      self.class.embedding_logger.error api_error_msg
      { success: false, processed: 0, message: api_error_msg, error_type: :api_error }
    end
  rescue StandardError => e
    general_error_msg = "❌ Unexpected error processing batch for #{model_name}: #{e.class.name} - #{e.message}"
    Rails.logger.error general_error_msg
    Rails.logger.error "Backtrace: #{e.backtrace[0..3].join('; ')}"
    self.class.embedding_logger.error general_error_msg
    { success: false, processed: 0, message: general_error_msg, error_type: :general_error }
  end

  def extract_text_content(record)
    text = case record
           when Practice
             [record.title, record.description].compact.join(' ')
           when Report
             [record.title, record.description].compact.join(' ')
           when Product
             record.body
           when Page
             [record.title, record.body].compact.join(' ')
           when Question
             # NOTE: Questionにはbodyフィールドが存在しないため、titleとdescriptionのみ使用
             [record.title, record.description].compact.join(' ')
           when Announcement
             [record.title, record.description].compact.join(' ')
           when Event
             [record.title, record.description].compact.join(' ')
           when RegularEvent
             [record.title, record.description].compact.join(' ')
           when SubmissionAnswer
             record.description
           else
             Rails.logger.warn "Unknown model type for embedding generation: #{record.class.name}"
             nil
           end

    # テキスト長制限を適用（トークン制限を考慮した安全な長さ）
    limit_text_length(text)
  end

  def limit_text_length(text)
    return nil if text.blank?

    # Google AI APIの20,000トークン制限を考慮
    # 安全のため15,000文字以内に制限（概算で約6,000トークン）
    max_chars = 15_000

    if text.length > max_chars
      truncated_text = text[0...max_chars]
      Rails.logger.warn "Text truncated from #{text.length} to #{max_chars} characters for embedding generation"
      self.class.embedding_logger.warn "Text truncated from #{text.length} to #{max_chars} characters for embedding generation"
      truncated_text
    else
      text
    end
  end
end
