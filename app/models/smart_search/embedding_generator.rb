# frozen_string_literal: true

require 'google/cloud/ai_platform/v1'

module SmartSearch
  class EmbeddingGenerator
    include ErrorHandler

    def initialize
      GoogleCloudCredentials.setup_credentials!
      @project_id = GoogleCloudCredentials.project_id
      @location = 'asia-northeast1'
      @credentials_available = false
      
      begin
        @client = Google::Cloud::AIPlatform::V1::PredictionService::Client.new
        @credentials_available = true if @project_id.present?
      rescue StandardError => e
        Rails.logger.warn "Google Cloud AI Platform client initialization failed: #{e.message}"
        Rails.logger.warn "Embedding features will be disabled"
        @client = nil
      end
    end

    # トークン数を推定（概算）
    def estimate_token_count(text)
      return 0 if text.blank?

      # 日本語と英語の混在テキストでの概算
      # 1トークン ≈ 4文字（英語）、1-2文字（日本語）
      # 安全のため、より保守的な推定を使用
      normalized_text = normalize_text(text)
      (normalized_text.length / 2.5).ceil
    end

    # 複数テキストの合計トークン数を推定
    def estimate_batch_token_count(texts)
      texts.sum { |text| estimate_token_count(text) }
    end

    # トークン制限に収まる最適なバッチサイズを計算
    def calculate_optimal_batch_size(texts, max_tokens = Configuration::MAX_TOKENS)
      return 0 if texts.empty?

      optimal_size = 0
      cumulative_tokens = 0

      texts.each_with_index do |text, index|
        text_tokens = estimate_token_count(text)

        break unless cumulative_tokens + text_tokens <= max_tokens

        cumulative_tokens += text_tokens
        optimal_size = index + 1
      end

      optimal_size
    end

    def generate_embedding(text)
      return nil if text.blank?
      return nil unless @credentials_available

      normalized_text = normalize_text(text)
      return nil if normalized_text.blank?

      begin
        response = predict_embedding(normalized_text)
        parse_embedding_response(response)
      rescue StandardError => e
        handle_embedding_error(e, 'for single text')
        nil
      end
    end

    def generate_embeddings_batch(texts)
      return [] if texts.blank?
      return [] unless @credentials_available

      normalized_texts = texts.map { |text| normalize_text(text) }.compact
      return [] if normalized_texts.blank?

      begin
        response = predict_embeddings_batch(normalized_texts)
        parse_batch_embedding_response(response)
      rescue StandardError => e
        handle_embedding_error(e, 'for batch texts')
        []
      end
    end

    private

    def normalize_text(text)
      return '' if text.blank?

      # HTMLタグを除去
      text = ActionView::Base.full_sanitizer.sanitize(text)
      # 改行文字を空白に変換
      text = text.gsub(/\n+/, ' ')
      # 複数の空白を単一の空白に変換
      text = text.gsub(/\s+/, ' ')
      # 前後の空白を除去
      text.strip
    end

    def predict_embedding(text)
      endpoint = endpoint_path

      # Vertex AI Text Embeddings APIの正しい形式（text-multilingual-embedding-002用）
      # 正しいinstanceの形式は "content" フィールドを使用
      instance = Google::Protobuf::Value.new(
        struct_value: Google::Protobuf::Struct.new(
          fields: {
            'content' => Google::Protobuf::Value.new(string_value: text)
          }
        )
      )

      @client.predict(
        endpoint:,
        instances: [instance]
      )
    end

    def predict_embeddings_batch(texts)
      endpoint = endpoint_path

      instances = texts.map do |text|
        Google::Protobuf::Value.new(
          struct_value: Google::Protobuf::Struct.new(
            fields: {
              'content' => Google::Protobuf::Value.new(string_value: text)
            }
          )
        )
      end

      @client.predict(
        endpoint:,
        instances:
      )
    end

    def parse_embedding_response(response)
      # レスポンス構造をデバッグ出力
      SmartSearch::Logger.debug "Response structure: #{response.predictions.first}"

      prediction = response.predictions.first
      return nil unless prediction

      # text-multilingual-embedding-002の正しいレスポンス構造
      # 予測されるレスポンス形式: { "embeddings": { "values": [float, float, ...] } }
      fields = prediction.struct_value&.fields
      return nil unless fields&.has_key?('embeddings')

      embeddings_field = fields['embeddings']
      embedding_fields = embeddings_field.struct_value&.fields
      return nil unless embedding_fields&.has_key?('values')

      values_field = embedding_fields['values']
      # list_valueから実際の数値配列を取得
      values_field.list_value&.values&.map(&:number_value)
    end

    def parse_batch_embedding_response(response)
      response.predictions.map do |prediction|
        next nil unless prediction

        # text-multilingual-embedding-002の正しいレスポンス構造
        fields = prediction.struct_value&.fields
        next nil unless fields&.has_key?('embeddings')

        embeddings_field = fields['embeddings']
        embedding_fields = embeddings_field.struct_value&.fields
        next nil unless embedding_fields&.has_key?('values')

        values_field = embedding_fields['values']
        # list_valueから実際の数値配列を取得
        values_field.list_value&.values&.map(&:number_value)
      end.compact
    end

    def endpoint_path
      "projects/#{@project_id}/locations/#{@location}/publishers/google/models/#{Configuration::EMBEDDING_MODEL}"
    end
  end
end
