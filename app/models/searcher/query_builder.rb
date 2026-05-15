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

    # pg_bigm拡張が有効かチェック（結果をキャッシュ）
    def self.pg_bigm_available?
      return @pg_bigm_available if defined?(@pg_bigm_available)

      @pg_bigm_available = check_pg_bigm_extension
    end

    # テスト用: キャッシュをリセット
    def self.reset_pg_bigm_cache!
      remove_instance_variable(:@pg_bigm_available) if defined?(@pg_bigm_available)
    end

    # 検索キーワードからRansack用のパラメータを構築（SearchUserから呼ばれる）
    def build_params(columns)
      build_ransack_params(columns)
    end

    private

    def self.check_pg_bigm_extension
      result = ActiveRecord::Base.connection.select_value(
        "SELECT EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'pg_bigm')"
      )
      [true, 't'].include?(result)
    rescue StandardError
      false
    end
    private_class_method :check_pg_bigm_extension

    # pg_bigm GINインデックスを活用したLIKE検索
    # pg_bigmはLIKEのみ対応（ILIKEは非対応）
    # 日本語検索ではcase-sensitiveで実用上問題なし
    # 英字（login_name等）も検索語そのままマッチするため十分実用的
    def search_with_bigm(config)
      model = config[:model]
      keywords = Searcher.split_keywords(keyword)

      scope = build_bigm_scope(model, config, keywords)
      scope.distinct.order(updated_at: :desc).to_a
    end

    # pg_bigm検索のスコープを構築
    def build_bigm_scope(model, config, keywords)
      scope = model.all
      scope = scope.includes(*config[:includes]) if config[:includes].any?

      keywords.each do |word|
        escaped = sanitize_like(word)
        # case_sensitive: true → LIKE（pg_bigm GINインデックスが効く）
        # case_sensitive: false → ILIKE（pg_bigmインデックスが効かない）
        conditions = config[:columns].map do |col|
          model.arel_table[col].matches("%#{escaped}%", nil, true)
        end
        scope = scope.where(conditions.reduce(:or))
      end
      scope
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
