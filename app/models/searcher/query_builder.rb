# frozen_string_literal: true

class Searcher
  # Ransackクエリの構築を担当
  class QueryBuilder
    attr_reader :keyword

    def initialize(keyword)
      @keyword = keyword
    end

    # 検索キーワードからRansack用のパラメータを構築
    def build_params(columns)
      keywords = Searcher.split_keywords(keyword)
      column_key = columns.join('_or_')

      if keywords.size == 1
        { "#{column_key}_cont" => keywords.first }
      else
        { g: keywords.map { |word| { "#{column_key}_cont" => word } } }
      end
    end

    # 設定に基づいて具体的なモデルをRansackで検索
    def search_model(config)
      model = config[:model]
      ransack_params = build_params(config[:columns])
      search = model.ransack(ransack_params)

      results = search.result(distinct: true)
      results = results.includes(*config[:includes]) if config[:includes].any?
      results.order(updated_at: :desc).to_a
    end
  end
end
