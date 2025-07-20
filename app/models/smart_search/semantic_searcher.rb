# frozen_string_literal: true

module SmartSearch
  class SemanticSearcher
    SIMILARITY_THRESHOLD = 0.7
    DEFAULT_LIMIT = 50

    def initialize
      @embedding_generator = EmbeddingGenerator.new
    end

    def search(query, document_type: :all, limit: DEFAULT_LIMIT, similarity_threshold: SIMILARITY_THRESHOLD)
      return [] if query.blank?

      query_embedding = @embedding_generator.generate_embedding(query)
      return [] if query_embedding.nil?

      case document_type
      when :all
        search_all(query_embedding, limit, similarity_threshold)
      else
        search_by_type(document_type, query_embedding, limit, similarity_threshold)
      end
    end

    def hybrid_search(query, document_type: :all, limit: DEFAULT_LIMIT)
      semantic_results = search(query, document_type:, limit:)
      keyword_results = Searcher.search(query, document_type:)

      merge_results(semantic_results, keyword_results, limit)
    end

    private

    def search_all(query_embedding, limit, similarity_threshold)
      all_results = []

      searchable_models.each do |model_class|
        results = search_model(model_class, query_embedding, limit, similarity_threshold)
        all_results.concat(results)
      end

      all_results
        .sort_by { |result| -result[:similarity] }
        .first(limit)
        .map { |result| result[:record] }
    end

    def search_by_type(document_type, query_embedding, limit, similarity_threshold)
      model_class = type_to_model(document_type)
      return [] unless model_class

      results = search_model(model_class, query_embedding, limit, similarity_threshold)
      results.map { |result| result[:record] }
    end

    def search_model(model_class, query_embedding, limit, similarity_threshold)
      # neighbor gemを使用したクリーンなベクトル検索
      results = model_class
                .where.not(embedding: nil)
                .nearest_neighbors(:embedding, query_embedding, distance: 'cosine')
                .limit(limit)

      # 類似度閾値でフィルタリング
      filtered_results = results.select do |record|
        distance = record.neighbor_distance
        distance < (1 - similarity_threshold)
      end

      filtered_results.map do |record|
        {
          record:,
          similarity: 1 - record.neighbor_distance.to_f
        }
      end
    rescue StandardError => e
      Rails.logger.error "Error searching #{model_class.name}: #{e.message}"
      Rails.logger.error "Error details: #{e.backtrace[0..3].join('; ')}"
      []
    end

    def merge_results(semantic_results, keyword_results, limit)
      # 重複を除去しつつマージ
      merged = {}

      # セマンティック検索結果を追加（高い重み）
      semantic_results.each_with_index do |result, index|
        key = "#{result.class.name}_#{result.id}"
        merged[key] = {
          record: result,
          semantic_score: 1.0 - (index.to_f / semantic_results.length),
          keyword_score: 0.0
        }
      end

      # キーワード検索結果を追加（中程度の重み）
      keyword_results.each_with_index do |result, index|
        key = "#{result.class.name}_#{result.id}"
        if merged[key]
          merged[key][:keyword_score] = 1.0 - (index.to_f / keyword_results.length)
        else
          merged[key] = {
            record: result,
            semantic_score: 0.0,
            keyword_score: 1.0 - (index.to_f / keyword_results.length)
          }
        end
      end

      # 統合スコアでソートして返す
      merged.values
            .sort_by { |item| -(item[:semantic_score] * 0.7 + item[:keyword_score] * 0.3) }
            .first(limit)
            .map { |item| item[:record] }
    end

    def searchable_models
      [Practice, Report, Product, Page, Question, Announcement, Event, RegularEvent, FAQ, Answer]
    end

    def type_to_model(document_type)
      case document_type
      when :practices then Practice
      when :reports then Report
      when :products then Product
      when :pages then Page
      when :questions then Question
      when :announcements then Announcement
      when :events then Event
      when :regular_events then RegularEvent
      when :faqs then FAQ
      when :answers then Answer
      end
    end
  end
end
