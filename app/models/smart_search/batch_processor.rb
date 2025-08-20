# frozen_string_literal: true

module SmartSearch
  class BatchProcessor
    include ErrorHandler

    def initialize
      @generator = EmbeddingGenerator.new
    end

    def process_batch(records, model_name)
      text_contents = extract_texts(records)
      return success_result(0, 'No text content to process') if text_contents.empty?

      # トークン数をチェックして必要に応じてバッチサイズを調整
      estimated_tokens = @generator.estimate_batch_token_count(text_contents)

      if estimated_tokens > Configuration::MAX_TOKENS
        handle_large_batch(records, text_contents, model_name, estimated_tokens)
      else
        process_normal_batch(records, text_contents, model_name)
      end
    end

    private

    def extract_texts(records)
      records.map { |record| TextExtractor.extract_text_content(record) }.compact
    end

    def handle_large_batch(records, text_contents, model_name, estimated_tokens)
      optimal_size = @generator.calculate_optimal_batch_size(text_contents)

      if optimal_size.zero?
        error_msg = "Cannot process #{model_name} batch: Even single record exceeds token limit (#{estimated_tokens} tokens)"
        log_error(error_msg)
        error_result(error_msg, :token_limit)
      elsif optimal_size < records.length
        log_info("Batch too large (#{estimated_tokens} tokens), splitting #{records.length} → #{optimal_size} records for #{model_name}")
        split_and_process(records, text_contents, optimal_size, model_name)
      else
        process_normal_batch(records, text_contents, model_name)
      end
    end

    def split_and_process(records, text_contents, optimal_size, model_name)
      # 最適サイズでバッチを分割
      smaller_records = records[0...optimal_size]
      smaller_text_contents = text_contents[0...optimal_size]

      # 小さなバッチを処理
      current_result = process_normal_batch(smaller_records, smaller_text_contents, model_name)

      # 残りのレコードも処理
      remaining_records = records[optimal_size..]
      remaining_result = process_batch(remaining_records, model_name) if remaining_records.any?

      # 結果をマージ
      total_processed = current_result[:processed] + (remaining_result ? remaining_result[:processed] : 0)
      combined_success = current_result[:success] && (remaining_result ? remaining_result[:success] : true)

      success_result(total_processed, "Split batch processed: #{total_processed}/#{records.length} #{model_name} records", success: combined_success)
    end

    def process_normal_batch(records, text_contents, model_name)
      embeddings = @generator.generate_embeddings_batch(text_contents)

      if embeddings.empty?
        error_msg = "No embeddings generated for #{records.length} #{model_name} records"
        log_error(error_msg)
        return error_result(error_msg)
      end

      saved_count = save_embeddings(records, embeddings, model_name)
      success_msg = "Successfully saved #{saved_count}/#{records.length} embeddings for #{model_name}"
      log_info(success_msg)

      success_result(saved_count, success_msg)
    rescue Google::Cloud::InvalidArgumentError => e
      handle_api_error(e, model_name)
    rescue StandardError => e
      handle_general_error(e, model_name)
    end

    def save_embeddings(records, embeddings, model_name)
      saved_count = 0

      records.each_with_index do |record, index|
        next if index >= embeddings.length || embeddings[index].nil?

        begin
          vector_string = "[#{embeddings[index].join(',')}]"
          result = record.class.where(id: record.id).update_all(
            embedding: vector_string,
            updated_at: Time.current
          )
          saved_count += 1 if result == 1
        rescue StandardError => e
          log_error("Failed to save embedding for #{model_name} ID #{record.id}: #{e.message}")
        end
      end

      saved_count
    end

    def handle_api_error(error, model_name)
      if error.message.include?('token count')
        error_msg = "API Token Limit Error for #{model_name}: #{error.message}"
        log_error(error_msg)
        error_result(error_msg, :token_limit)
      else
        error_msg = "API Error for #{model_name}: #{error.message}"
        log_error(error_msg)
        error_result(error_msg, :api_error)
      end
    end

    def handle_general_error(error, model_name)
      error_msg = "Unexpected error processing batch for #{model_name}: #{error.class.name} - #{error.message}"
      log_error(error_msg)
      log_error("Backtrace: #{error.backtrace[0..3].join('; ')}")
      error_result(error_msg, :general_error)
    end

    def success_result(processed, message, success: true)
      { success:, processed:, message: }
    end

    def error_result(message, error_type = :general_error)
      { success: false, processed: 0, message:, error_type: }
    end
  end
end
