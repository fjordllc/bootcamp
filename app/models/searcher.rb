# frozen_string_literal: true

class Searcher
  include SearchHelper

  DOCUMENT_TYPES = [
    ['すべて', :all], ['お知らせ', :announcements], ['プラクティス', :practices],
    ['日報', :reports], ['提出物', :products], ['Q&A', :questions],
    ['Docs', :pages], ['イベント', :events], ['定期イベント', :regular_events],
    ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers]

  def self.fetch_url(searchable)
      searchable_url(searchable)
  rescue NoMethodError
      nil
  end

  def self.search(word, current_user:, document_type: :all)
    words = word.split(/[[:blank:]]+/).reject(&:blank?)
    searchables = case document_type
                  when :all
                    result_for_all(word)
                  when commentable?(document_type)
                    result_for_comments(document_type, word)
                  when :questions
                    result_for_questions(document_type, word)
                  else
                    result_for(document_type, word).sort_by(&:updated_at).reverse
                  end

    searchables = if current_user.admin?
                    searchables.reject { |searchable| searchable.instance_of?(Talk) }
                  else
                    searchables.reject do |searchable|
                      searchable.instance_of?(Talk) && searchable.user_id != current_user.id
                    end
                  end

    delete_comment_of_talk!(searchables, current_user)

    searchables.map do |searchable|
      SearchResult.new(searchable, word, current_user)
    end
  end

  def self.fetch_login_name(searchable)
    User.find_by(id: searchable.try(:user_id))&.login_name
  end

  def self.fetch_commentable_user(searchable)
    if searchable.is_a?(Answer) || searchable.is_a?(CorrectAnswer)
      searchable.question&.user
    else
      searchable.try(:commentable)&.try(:user)
    end
  end

  def self.fetch_title(searchable)
    if searchable.is_a?(Answer)
      searchable.question&.title
    elsif searchable.is_a?(User)
      searchable.login_name
    else
      searchable.try(:title)
    end
  end

  def self.fetch_label(searchable)
    if searchable.is_a?(User)
      searchable.avatar_url
    elsif searchable.is_a?(Talk)
      nil
    else
      searchable.label
    end
  end

  def self.result_for_all(words)
    user_filter = words.find { |word| word.match(/^user:(\w+)$/) }
    if user_filter
      username = user_filter.delete_prefix('user:')
      user = User.find_by(login_name: username)
      return [] unless user

      AVAILABLE_TYPES
        .reject { |type| type == :users }
        .flat_map do |type|
          model = model(type)
          next [] unless model.column_names.include?('user_id') || model.column_names.include?('last_updated_user_id')

          if type == :practices
            model.where('last_updated_user_id = ?', user.id)
          else
            model.where(user_id: user.id)
          end
        end
        .uniq
        .select { |result| words.all? { |word| result_matches_keyword?(result, word) } }
        .sort_by(&:updated_at)
        .reverse
    else
      AVAILABLE_TYPES
        .flat_map { |type| result_for(type, words) }
        .uniq
        .select { |result| words.all? { |word| result_matches_keyword?(result, word) } }
        .sort_by(&:updated_at)
        .reverse
    end
  end

  def self.result_for(type, words, commentable_type: nil)
    raise ArgumentError, "#{type} is not an available type" unless type.in?(AVAILABLE_TYPES)

    return model(type).all if words.blank?

    user_filter = words.find { |word| word.match(/^user:(\w+)$/) }
    if user_filter
      username = user_filter.delete_prefix('user:')
      user = User.find_by(login_name: username)
      return [] unless user

      results = if type == :practices
                  model(type).where('user_id = ? OR last_updated_user_id = ?', user.id, user.id)
                else
                  model(type).where(user_id: user.id)
                end
    else
      results = if commentable?(type)
                  model(type).search_by_keywords(words:, commentable_type:) +
                    Comment.search_by_keywords(words:, commentable_type: model_name(type))
                else
                  model(type).search_by_keywords(words:, commentable_type:)
                end
    end
    results.select { |result| words.all? { |word| result_matches_keyword?(result, word) } }
  end

  def self.result_matches_keyword?(result, word)
    return false unless result

    if word =~ /^user:(\w+)$/
      username = Regexp.last_match(1)
      return result.user&.login_name == username unless result.is_a?(Practice)

        user = User.find_by(id: result.last_updated_user_id)
        return user&.login_name == username

    end
    searchable_fields = [result.try(:title), result.try(:body), result.try(:description)]
    searchable_fields.any? { |field| field.to_s.include?(word) }
  end

  def self.result_for_comments(document_type, word)
    [document_type, :comments].flat_map do |type|
      result_for(type, word, commentable_type: model_name(document_type))
    end.uniq.sort_by(&:updated_at).reverse
  end

  def self.result_for_questions(document_type, word)
    [document_type, :answers].flat_map { |type| result_for(type, word) }.sort_by(&:updated_at).reverse
  end

  def self.model(type)
    model_name(type).constantize
  end

  def self.model_name(type)
    type.to_s.camelize.singularize
  end

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
