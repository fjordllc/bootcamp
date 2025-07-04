# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ['すべて', :all], ['お知らせ', :announcements], ['プラクティス', :practices],
    ['日報', :reports], ['提出物', :products], ['Q&A', :questions],
    ['Docs', :pages], ['イベント', :events], ['定期イベント', :regular_events],
    ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers]

  class << self
    include SearchHelper

    def search(word, current_user:, document_type: :all)
      words = word.split(/[[:blank:]]+/).reject(&:blank?)
      searchables = fetch_results(words, document_type) || []
      filter_results!(searchables, current_user).map do |searchable|
        SearchResult.new(searchable, word, current_user)
      end
    end

    private

    def fetch_results(words, document_type)
      return results_for_all(words) if document_type == :all

      model = model(document_type)
      return result_for_comments(document_type, words) if model.include?(Commentable)
      return result_for_questions(document_type, words) if document_type == :questions

      result_for(document_type, words) || []
    end

    def results_for_all(words)
      user_filter = words.find { |word| word.match(/^user:(\w+)$/) }&.delete_prefix('user:')
      return search_by_user_filter(user_filter, words) if user_filter

      AVAILABLE_TYPES.filter_map { |type| result_for(type, words) }
                     .flatten
                     .uniq
                     .sort_by(&:updated_at)
                     .reverse
    end

    def result_for(type, words)
      raise ArgumentError, "#{type} is not available" unless type.in?(AVAILABLE_TYPES)

        user = User.find_by(id: result.last_updated_user_id)
        return user&.login_name == username

    end
    searchable_fields = [result.try(:title), result.try(:body), result.try(:description)]
    searchable_fields.any? { |field| field.to_s.include?(word) }
  end

    def result_for_comments(document_type, words)
      results = result_for(document_type, words) || []
      comment_results = result_for(:comments, words)&.select do |comment|
        comment.commentable_type == search_model_name(document_type)
      end || []

  def self.commentable?(document_type)
    model(document_type).include?(Commentable)
  end

  def self.delete_comment_of_talk_and_inquiry!(searchables, current_user)
    searchables.reject! do |searchable|
      searchable.commentable.user_id != current_user.id && !current_user.admin? if searchable.instance_of?(Comment) && searchable.commentable.instance_of?(Talk) && searchable.commentable.instance_of?(Inquiry)
    end

    def visible_to_user?(searchable, current_user)
      case searchable
      when Talk
        current_user.admin? || searchable.user_id == current_user.id
      when Comment
        if searchable.commentable.is_a?(Talk)
          current_user.admin? || searchable.commentable.user_id == current_user.id
        else
          true
        end
      when User, Practice, Page, Event, RegularEvent, Announcement, Report, Product, Question, Answer
        true
      else
        false
      end
    end

    def filter_results!(searchables, current_user)
      searchables&.select { |searchable| visible_to_user?(searchable, current_user) }
    end

    def visible_to_user?(searchable, current_user)
      case searchable
      when Talk
        current_user.admin? || searchable.user_id == current_user.id
      when Comment
        if searchable.commentable.is_a?(Talk)
          current_user.admin? || searchable.commentable.user_id == current_user.id
        else
          true
        end
      when User, Practice, Page, Event, RegularEvent, Announcement, Report, Product, Question, Answer
        true
      else
        false
      end
    end

    def model(type)
      search_model_name(type)&.constantize
    end

    def search_model_name(type)
      return nil if type == :all

      type.to_s.camelize.singularize
    end

    def search_by_user_filter(username, words)
      user = User.find_by(login_name: username) or return []
      filter_by_keywords(search_by_user_id(user.id), words)
    end

    def search_by_user_id(user_id)
      AVAILABLE_TYPES.reject { |type| type == :users }
                     .flat_map { |type| model(type).where(user_filter_condition(type, user_id)) }
    end

    def user_filter_condition(type, user_id)
      type == :practices ? { last_updated_user_id: user_id } : { user_id: }
    end

    def search_users(words)
      User.where(words.map { |_word| 'login_name ILIKE ? OR name ILIKE ? OR description ILIKE ?' }
                      .join(' AND '), *words.flat_map { |word| ["%#{word}%"] * 3 })
    end

    def filter_by_keywords(results, words)
      return results if words.empty?

      (results || []).select { |result| words.all? { |word| result_matches_keyword?(result, word) } }
                     .sort_by(&:updated_at)
                     .reverse
    end

    def result_matches_keyword?(result, word)
      return extract_user_id_match(result, word) if word.match?(/^user:/)

      [result.try(:title), result.try(:body), result.try(:description)]
        .any? { |field| field.to_s.downcase.include?(word.downcase) }
    end

    def extract_user_id_match(result, word)
      user_id = word.delete_prefix('user:')
      return result.user&.login_name&.casecmp?(user_id) if result.respond_to?(:user) && result.user.present?
      if result.respond_to?(:last_updated_user_id) && result.last_updated_user_id.present?
        return User.find_by(id: result.last_updated_user_id)&.login_name&.casecmp?(user_id)
      end

      false
    end
  end

  def self.highlight_word(text, word)
    return text unless text.present? && word.present?

    sanitized_word = Regexp.escape(word)
    text.gsub(/(#{sanitized_word})/i, '<strong class="matched_word">\1</strong>')
  end
end
