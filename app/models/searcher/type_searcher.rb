# frozen_string_literal: true

class Searcher
  # タイプ別の検索ロジックを担当
  class TypeSearcher
    attr_reader :query_builder, :document_type

    def initialize(query_builder, document_type)
      @query_builder = query_builder
      @document_type = document_type
    end

    # タイプに応じた検索を実行
    def search
      if document_type == :all
        search_all_types
      else
        search_specific_type(document_type)
      end
    end

    private

    # 全タイプのモデルを検索して結果を結合
    def search_all_types
      Configuration.configurations.flat_map do |_type, config|
        query_builder.search_model(config)
      end
    end

    # 特定タイプのモデルを検索し、関連するコメントや回答も含める
    def search_specific_type(type)
      config = Configuration.get(type)
      return [] unless config

      results = query_builder.search_model(config)
      results += search_comments_for_type(type) if type != :comment
      results += search_related_answers if type == :question
      results
    end

    # 質問に関連する回答を検索
    def search_related_answers
      answer_results = query_builder.search_model(Configuration.get(:answer))
      correct_answer_results = query_builder.search_model(Configuration.get(:correct_answer))
      answer_results + correct_answer_results
    end

    # 特定タイプのモデルに関連するコメントを検索
    def search_comments_for_type(type)
      config = Configuration.get(:comment)
      target_config = Configuration.get(type)
      return [] unless config && target_config

      comments = query_builder.search_model(config)
      comments.select { |comment| comment.commentable_type == target_config[:model].name }
    end
  end
end
