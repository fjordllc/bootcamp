# frozen_string_literal: true

class Searcher
  # 検索クエリの構築を担当
  # pg_bigmが利用可能な場合はLIKEで検索（GINインデックスが効く）
  # 利用不可の場合はRansack（ILIKE）にフォールバック
  class QueryBuilder
    attr_reader :keyword

    def initialize(keyword)
      @keyword = keyword
    end

    # 設定に基づいて具体的なモデルを検索
    # pg_bigm利用時もassociation経由のカラムがある場合はRansackにフォールバック
    def search_model(config)
      if self.class.pg_bigm_available? && own_columns_only?(config)
        search_with_bigm(config)
      else
        search_with_ransack(config)
      end
    end

    def self.pg_bigm_available?
      return @pg_bigm_available if defined?(@pg_bigm_available)

      @pg_bigm_available = begin
        result = ActiveRecord::Base.connection.execute(
          "SELECT COUNT(*) FROM pg_extension WHERE extname = 'pg_bigm'"
        )
        result.first["count"].to_i.positive?
      rescue StandardError
        false
      end
    end

    def self.reset_pg_bigm_cache!
      remove_instance_variable(:@pg_bigm_available) if defined?(@pg_bigm_available)
    end

    private

    # pg_bigm GINインデックスを活用したLIKE検索
    def search_with_bigm(config)
      model = config[:model]
      columns = config[:columns]
      keywords = Searcher.split_keywords(keyword)

      scope = model.all
      scope = scope.includes(*config[:includes]) if config[:includes].any?

      keywords.each do |word|
        escaped = sanitize_like(word)
        conditions = columns.map do |col|
          # case_sensitive: true → LIKEを使用（pg_bigm GINインデックスが効く）
          model.arel_table[col].matches("%#{escaped}%", nil, true)
        end
        scope = scope.where(conditions.reduce(:or))
      end

      scope.distinct.order(updated_at: :desc).to_a
    end

    # Ransack（ILIKE）によるフォールバック検索
    def search_with_ransack(config)
      model = config[:model]
      ransack_params = build_ransack_params(config[:columns])
      search = model.ransack(ransack_params)

      results = search.result(distinct: true)
      results = results.includes(*config[:includes]) if config[:includes].any?
      results.order(updated_at: :desc).to_a
    end

    # 検索キーワードからRansack用のパラメータを構築
    def build_ransack_params(columns)
      keywords = Searcher.split_keywords(keyword)
      column_key = columns.join('_or_')

      if keywords.size == 1
        { "#{column_key}_cont" => keywords.first }
      else
        { g: keywords.map { |word| { "#{column_key}_cont" => word } } }
      end
    end

    # モデル自身のカラムのみか（association経由のカラムが含まれないか）
    def own_columns_only?(config)
      model = config[:model]
      column_names = model.column_names
      config[:columns].all? { |col| column_names.include?(col.to_s) }
    end

    # LIKE用の特殊文字をエスケープ
    def sanitize_like(str)
      str.gsub(/[\\%_]/) { |c| "\\#{c}" }
    end
  end
end
