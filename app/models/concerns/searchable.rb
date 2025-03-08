# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  COLUMN_NAMES_FOR_SEARCH_USER_ID = %i[user_id last_updated_user_id].freeze

  included do
    # 拡張する場合はこのスコープを上書きする
    scope :search_by_keywords_scope, -> { all } if self < ActiveRecord::Base
  end

  class_methods do
    def search_by_keywords(searched_values = {})
      ransack(**params_for_keyword_search(searched_values)).result.search_by_keywords_scope
    end

    def columns_for_keyword_search(*column_names)
      define_singleton_method(:_join_column_names) do
        "#{(column_names + [:kana_name]).join('_or_')}_cont_any"
      end
    end

    private

    def params_for_keyword_search(searched_values = {})
      word = searched_values[:word].to_s.strip
      return {} if word.blank?

      { combinator: 'or', groupings: [word_to_groupings(word)] }
    end

    def word_to_groupings(word)
      return { _join_column_names => word } unless contains_user_id_column?

      word.start_with?('user:') ? search_user_id(word.delete_prefix('user:')) : { _join_column_names => word }
    end

    def contains_user_id_column?
      COLUMN_NAMES_FOR_SEARCH_USER_ID.any? { |column_name| has_attribute?(column_name) }
    end

    def search_user_id(username)
      user = User.find_by(login_name: username)
      { "#{COLUMN_NAMES_FOR_SEARCH_USER_ID.join('_or_')}_eq" => user&.id || 0 }
    end
  end

  def primary_role
    return user_role if is_a?(User)
    return user_role(user) if respond_to?(:user) && user.present?

    nil
  end

  def formatted_updated_at
    return formatted_updated_at if is_a?(SearchResult)

    weekdays = %w[日 月 火 水 木 金 土]
    updated_at.strftime("%Y年%m月%d日(#{weekdays[updated_at.wday]}) %H:%M")
  end

  def label
    return avatar_url if model_name.name.casecmp?('User')

    case model_name.name.downcase
    when 'regularevent' then "定期\nイベント"
    when 'event' then "特別\nイベント"
    when 'practice' then "プラク\nティス"
    when 'correctanswer', 'answer' then 'Q&A'
    when 'comment' then comment_label
    else
      I18n.t("activerecord.models.#{model_name.name.underscore}")
    end
  end

  def user_role(user = self)
    return 'admin' if user.admin?
    return 'mentor' if user.mentor?
    return 'adviser' if user.adviser?
    return 'trainee' if user.trainee?
    return 'graduate' if user.graduated?

    'student' if user.student?
  end

  def comment_label
    return 'コメント' unless respond_to?(:commentable) && commentable.present?

    case commentable_type
    when 'Announcement' then 'お知らせ'
    when 'Practice' then "プラク\nティス"
    when 'Report' then '日報'
    when 'Product' then '提出物'
    when 'Question' then 'Q&A'
    when 'Page' then 'Docs'
    when 'Event' then "特別\nイベント"
    when 'RegularEvent' then "定期\nイベント"
    else 'コメント'
    end
  end
end
