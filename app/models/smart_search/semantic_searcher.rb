# frozen_string_literal: true

module SmartSearch
  class SemanticSearcher
    def initialize
      @generator = EmbeddingGenerator.new
    end

    def search(query, document_type: :all, limit: Configuration::DEFAULT_LIMIT)
      perform_search(query, document_type, limit)
    rescue StandardError => e
      Rails.logger.error "[SmartSearch] Semantic search failed: #{e.message}"
      []
    end

    private

    def perform_search(query, document_type, limit)
      return [] if query.blank?
      return [] unless @generator.api_available?

      query_embedding = @generator.generate(query)
      return [] if query_embedding.blank?

      results = search_by_type(query_embedding, document_type, limit)
      results.sort_by { |r| r[:distance] }.first(limit).map { |r| r[:record] }
    end

    def search_by_type(query_embedding, document_type, limit)
      if document_type == :all
        search_all_types(query_embedding, limit)
      else
        search_specific_type(query_embedding, document_type, limit)
      end
    end

    def search_all_types(query_embedding, limit)
      Configuration.embedding_models.flat_map do |model_class|
        search_model(model_class, query_embedding, limit)
      end
    end

    def search_specific_type(query_embedding, document_type, limit)
      model_class = type_to_model(document_type)
      return [] unless model_class

      search_model(model_class, query_embedding, limit)
    end

    def search_model(model_class, query_embedding, limit)
      return [] unless model_class.column_names.include?('embedding')

      # Use raw SQL for vector similarity search
      table_name = model_class.table_name
      embedding_str = "[#{query_embedding.join(',')}]"

      model_class
        .where.not(embedding: nil)
        .select("#{table_name}.*, embedding <=> '#{embedding_str}' AS neighbor_distance")
        .order(Arel.sql("embedding <=> '#{embedding_str}'"))
        .limit(limit)
        .map { |record| { record:, distance: record.neighbor_distance } }
    rescue StandardError => e
      Rails.logger.error "[SmartSearch] Search failed for #{model_class}: #{e.message}"
      []
    end

    def type_to_model(document_type)
      config = Searcher::Configuration::CONFIGS[document_type.to_sym]
      config&.dig(:model)
    end
  end
end
