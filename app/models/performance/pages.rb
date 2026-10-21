# frozen_string_literal: true

module Performance
  module Pages
    REGISTRY = {
      'dashboard' => %w[home index ダッシュボード],
      'reports_index' => %w[reports index 日報一覧],
      'reports_show' => %w[reports show 日報詳細],
      'products_index' => %w[products index 提出物一覧],
      'products_show' => %w[products show 提出物詳細],
      'questions_index' => %w[questions index 質問一覧],
      'questions_show' => %w[questions show 質問詳細],
      'practice_show' => %w[practices show プラクティス詳細],
      'users_index' => %w[users index ユーザー一覧],
      'users_show' => %w[users show ユーザー詳細]
    }.transform_values(&:freeze).freeze
    DEVICES = %w[desktop mobile].freeze
    METRICS = %w[LCP INP CLS].freeze
    STATES = %w[observed unsupported unobserved].freeze
    SAMPLE_RATE = 0.20

    def self.key_for(controller, action)
      REGISTRY.find { |_key, values| values.first(2) == [controller, action] }&.first
    end
  end
end
