# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  REQUIRED_SEARCH_METHODS = %i[search_title search_label search_url].freeze

  # ベクトル類似度検索はSemanticSearcherで生SQLを使用して処理
  # クラスロード時のデータベース利用可否問題を回避するため

  included do
    after_commit :schedule_embedding_generation, on: %i[create update], if: :should_generate_embedding?
  end

  class_methods do
    def columns_for_keyword_search(*columns)
      define_singleton_method :ransackable_attributes do |_auth_object = nil|
        columns.map(&:to_s)
      end
    end
  end

  def search_title
    try(:title) || self.class.model_name.human
  end

  def search_label
    I18n.t("activerecord.search_labels.#{self.class.model_name.i18n_key}", default: -> { self.class.model_name.human })
  end

  def search_thumbnail
    return avatar_url if is_a?(User)

    nil
  end

  def search_url
    url_helpers = Rails.application.routes.url_helpers
    url_helpers.polymorphic_path(self)
  rescue ActionController::UrlGenerationError, NoMethodError
    '#'
  end

  def search_user_id
    is_a?(User) ? id : try(:user_id)
  end

  # リソースのアンダースコア形式のクラス名を返す
  # CSSクラスやテンプレート選択に使用
  def search_model_name
    self.class.name.underscore
  end

  # コメント可能オブジェクトに関連するユーザーを返す
  def search_commentable_user
    return question&.user if is_a?(Answer) || is_a?(CorrectAnswer)

    try(:commentable)&.try(:user)
  end

  # コメント可能オブジェクトのローカライズされたモデル名を返す
  # 検索結果での人間が読みやすいタイプラベル表示に使用
  def search_commentable_type
    return '' unless try(:commentable)

    model_name = commentable.model_name.name.underscore
    I18n.t("activerecord.models.#{model_name}", default: '')
  end

  # 検索対象となる基本コンテンツを返す
  def search_content
    try(:description) || try(:body) || ''
  end

  # 検索での可視性チェック（デフォルト実装、各モデルでオーバーライド可能）
  def visible_to_user?(_user)
    true
  end

  # 検索結果に表示するプライマリロールを返す
  def primary_role
    return user_role if is_a?(User)
    return user_role(user) if respond_to?(:user) && user.present?

    nil
  end

  # ユーザーのロールを判定して文字列で返す
  def user_role(user = self)
    return 'admin' if user.admin?
    return 'mentor' if user.mentor?
    return 'adviser' if user.adviser?
    return 'trainee' if user.trainee?
    return 'graduate' if user.graduated?

    'student' if user.student?
  end

  # embedding生成用のテキストを返す
  # 各モデルで必要に応じてオーバーライド
  def text_for_embedding
    text = [try(:title), try(:description)].compact.join("\n\n")
    truncate_for_embedding(text)
  end

  private

  def truncate_for_embedding(text)
    return nil if text.blank?

    max_length = SmartSearch::Configuration::MAX_TEXT_LENGTH
    text.length > max_length ? text[0...max_length] : text
  end

  def schedule_embedding_generation
    EmbeddingGenerateJob.perform_later(model_name: self.class.name, record_id: id)
  end

  def should_generate_embedding?
    return false unless self.class.column_names.include?('embedding')

    SmartSearch::Configuration::EMBEDDING_MODELS.include?(self.class.name)
  end
end
