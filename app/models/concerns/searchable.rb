# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  COLUMN_NAMES_FOR_SEARCH_USER_ID = %i[user_id last_updated_user_id].freeze

  included do
    scope :search_by_keywords_scope, -> { all }
  end

  class_methods do
    def search_by_keywords(searched_values = {})
      ransack(**params_for_keyword_search(searched_values)).result.search_by_keywords_scope
    end

    def columns_for_keyword_search(*column_names)
      define_singleton_method(:_join_column_names) { "#{(column_names + %i[kana_name]).join('_or_')}_cont_any" }
    end

    private

    def params_for_keyword_search(searched_values = {})
      return {} if searched_values[:word].blank?

      word = searched_values[:word].strip

      { combinator: 'or', groupings: [word_to_groupings(word)] }
    end

    def word_to_groupings(word)
      return { _join_column_names => word } if COLUMN_NAMES_FOR_SEARCH_USER_ID.none? { |column_name| has_attribute?(column_name) }

      if word.match?(/^user:/)
        create_parameter_for_search_user_id(word.delete_prefix("user:"))
      else
        { _join_column_names => word }
      end
    end

    def split_keyword_by_blank(word)
      word.split(/[[:blank:]]/)
    end

    def create_parameter_for_search_user_id(username)
      user = User.find_by(login_name: username)
      { "#{%i[user_id last_updated_user_id].join('_or_')}_eq" => user&.id || 0 }
    end
  end

  def primary_role
    if is_a?(User)
      return 'admin' if admin?
      return 'mentor' if mentor?
      return 'adviser' if adviser?
      return 'trainee' if trainee?
      return 'graduate' if graduated?
      return 'student' if student?
    elsif respond_to?(:user) && user.present?
      return 'admin' if user.admin?
      return 'mentor' if user.mentor?
      return 'adviser' if user.adviser?
      return 'trainee' if user.trainee?
      return 'graduate' if user.graduated?
      return 'student' if user.student?
    end
    nil
  end

  def formatted_updated_at
    if is_a?(SearchResult)
      formatted_updated_at
    else
      weekdays = { 'Sunday' => '日', 'Monday' => '月', 'Tuesday' => '火', 'Wednesday' => '水',
                   'Thursday' => '木', 'Friday' => '金', 'Saturday' => '土' }
      day_name = updated_at.strftime('%A')
      updated_at.strftime("%Y年%m月%d日(#{weekdays[day_name]}) %H:%M")
    end
  end

  def label
    if model_name.name.casecmp('user').zero?
      avatar_url
    else
      case model_name.name.downcase
      when 'regularevent'
        "定期\nイベント"
      when 'event'
        "特別\nイベント"
      when 'practice'
        "プラク\nティス"
      when 'correctanswer'
        'Q&A'
      when 'comment'
        if respond_to?(:commentable) && commentable.present?
          case commentable_type
          when 'Announcement'
            'お知らせ'
          when 'Practice'
            "プラク\nティス"
          when 'Report'
            '日報'
          when 'Product'
            '提出物'
          when 'Question'
            'Q&A'
          when 'Page'
            'Docs'
          when 'Event'
            "特別\nイベント"
          when 'RegularEvent'
            "定期\nイベント"
          else
            'コメント'
          end
        else
          'コメント'
        end
      else
        model_name.name == 'Answer' ? 'Q&A' : I18n.t("activerecord.models.#{model_name.name.underscore}")
      end
    end
  end
end
