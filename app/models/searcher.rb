# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ['すべて', :all], ['お知らせ', :announcements], ['プラクティス', :practices],
    ['日報', :reports], ['提出物', :products], ['Q&A', :questions],
    ['Docs', :pages], ['イベント', :events], ['定期イベント', :regular_events],
    ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers]

  def self.search(word, document_type: :all)
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

    delete_comment_of_talk!(searchables)

    searchables.map do |searchable|
      searchable.instance_variable_set(:@highlight_word, word)

      {
        url: searchable.try(:url),
        title: fetch_title(searchable),
        summary: searchable.try(:summary),
        formatted_summary: searchable.formatted_summary(word),
        user_id: searchable.is_a?(User) ? searchable.id : searchable.try(:user_id),
        login_name: searchable.try(:login_name),
        formatted_updated_at: searchable.formatted_updated_at,
        model_name: searchable.class.name.underscore,
        label: fetch_label(searchable),
        wip: searchable.try(:wip),
        commentable_user: searchable.try(:commentable)&.try(:user),
        commentable_type: I18n.t("activerecord.models.#{searchable.try(:commentable)&.try(:model_name)&.name&.underscore}", default: ''),
        primary_role: searchable.primary_role
      }
    end
  end

  def self.fetch_title(searchable)
    if searchable.is_a?(Answer)
      searchable.question&.title
    else
      searchable.try(:title)
    end
  end

  def self.fetch_label(searchable)
    if searchable.is_a?(User)
      searchable.avatar_url
    else
      searchable.label
    end
  end

  def self.result_for_all(word)
    AVAILABLE_TYPES
      .flat_map { |type| result_for(type, word) }
      .sort_by(&:updated_at)
      .reverse
  end

    def result_for_comments(document_type, word)
      [document_type, :comments].flat_map do |type|
        result_for(type, word, commentable_type: model_name(document_type))
      end.sort_by(&:updated_at).reverse
    end

    def result_for_questions(document_type, word)
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

  def self.delete_comment_of_talk_and_inquiry!(searchables)
    searchables.reject do |searchable|
      searchable.instance_of?(Comment) && searchable.commentable.instance_of?(Talk) && searchable.commentable.instance_of?(Inquiry)
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
    return '' unless text.present? && word.present?

    sanitized_word = Regexp.escape(word)
    text.gsub(/(#{sanitized_word})/i, '<strong class="matched_word">\1</strong>')
  end
end
