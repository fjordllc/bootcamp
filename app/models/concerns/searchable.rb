# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  COLUMN_NAMES_FOR_SEARCH_USER_ID = %i[user_id last_updated_user_id].freeze

  included do
    scope :search_by_keywords_scope, -> { all }

    def url
      raise NotImplementedError, "#{self.class} must implement #url method"
    end
  end

  class_methods do
    def search_by_keywords(searched_values = {})
      ransack(**params_for_keyword_search(searched_values)).result.search_by_keywords_scope
    end

    def columns_for_keyword_search(*column_names)
      define_singleton_method(:_join_column_names) { "#{column_names.join('_or_')}_cont_all" }
    end

    private

    def params_for_keyword_search(searched_values = {})
      return {} if searched_values[:word].blank?

      groupings = split_keyword_by_blank(searched_values[:word])
                  .map { |word| word_to_groupings(word) }

      { groupings: }
    end

    def word_to_groupings(word)
      return { _join_column_names => word } if COLUMN_NAMES_FOR_SEARCH_USER_ID.none? { |column_name| has_attribute?(column_name) }

      case word
      when /user:(.*)/
        create_parameter_for_search_user_id(Regexp.last_match(1))
      else
        { _join_column_names => word }
      end
    end

    def split_keyword_by_blank(word)
      word.split(/[[:blank:]]/)
    end

    def create_parameter_for_search_user_id(name)
      user = User.find_by(login_name: name)
      { "#{COLUMN_NAMES_FOR_SEARCH_USER_ID.join('_or_')}_eq" => user&.id || 0 }
    end
  end

  def css_class
    if wip
      "is-wip is-#{model_name}"
    else
      "is-#{model_name}"
    end
  end

  def role_class
    "is-#{primary_role}" if respond_to?(:primary_role)
  end

  def primary_role
    return unless respond_to?(:user) && user.present?

    if user.admin?
      'admin'
    elsif user.mentor?
      'mentor'
    elsif user.adviser?
      'adviser'
    elsif user.trainee?
      'trainee'
    elsif user.student?
      'student'
    end
  end

  def formatted_updated_at
    weekdays = { 'Sunday' => '日', 'Monday' => '月', 'Tuesday' => '火', 'Wednesday' => '水',
                 'Thursday' => '木', 'Friday' => '金', 'Saturday' => '土' }
    day_name = updated_at.strftime('%A')
    updated_at.strftime("%Y年%m月%d日(#{weekdays[day_name]}) %H:%M")
  end

  def label
    case model_name.name.downcase
    when 'regularevent'
      "定期\nイベント"
    when 'event'
      "特別\nイベント"
    when 'practice'
      "プラク\nティス"
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
        when 'Regularevent'
          "定期\nイベント"
        else
          'コメント'
        end
      else
        'コメント'
      end
    else
      I18n.t("activerecord.models.#{model_name.name.underscore}")
    end
  end

  def talk_url_for_admin
    "/talks/#{talk_id}" if talk_id.present?
  end
end
