# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  REQUIRED_SEARCH_METHODS = %i[search_title search_label search_url].freeze

  included do
    if table_exists? && column_names.include?('embedding')
      has_neighbors :embedding, dimensions: 1536

      after_commit :schedule_embedding_generation, on: %i[create update],
                                                   if: :should_generate_embedding?
    end
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

  private

  def should_generate_embedding?
    return false unless self.class.column_names.include?('embedding')
    return false if Rails.env.test? && !ENV['ENABLE_EMBEDDING_IN_TEST']

    embedding_content_changed?
  end

  def embedding_content_changed?
    relevant_columns = %i[title description body goal]
    relevant_columns.any? do |column|
      respond_to?("#{column}_previously_changed?") &&
        send("#{column}_previously_changed?")
    end
  end

  def schedule_embedding_generation
    EmbeddingGenerateJob.perform_later(
      model_name: self.class.name,
      record_id: id
    )
  end
end
