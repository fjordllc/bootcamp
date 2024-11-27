# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ['すべて', :all],
    ['お知らせ', :announcements],
    ['プラクティス', :practices],
    ['日報', :reports],
    ['提出物', :products],
    ['Q&A', :questions],
    ['Docs', :pages],
    ['イベント', :events],
    ['定期イベント', :regular_events],
    ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers]

  def self.search(word, document_type: :all)
    words = word.split(/[[:blank:]]+/)
    searchables = case document_type
                  when :all
                    result_for_all(words)
                  when commentable?(document_type)
                    result_for_comments(document_type, words)
                  when :questions
                    result_for_questions(document_type, words)
                  else
                    result_for(document_type, words).sort_by(&:updated_at).reverse
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
        commentable_user: fetch_commentable_user(searchable),
        commentable_type: I18n.t("activerecord.models.#{searchable.try(:commentable)&.try(:model_name)&.name&.underscore}", default: ''),
        primary_role: searchable.primary_role
      }
    end
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

  def self.result_for_all(words)
    AVAILABLE_TYPES
      .flat_map { |type| result_for(type, words) }
      .sort_by(&:updated_at)
      .reverse
  end

  def self.result_for(type, words, commentable_type: nil)
    raise ArgumentError, "#{type} is not an available type" unless type.in?(AVAILABLE_TYPES)

    if commentable?(type)
      model(type).search_by_keywords(words:, commentable_type:) +
        Comment.search_by_keywords(words:, commentable_type: model_name(type))
    else
      model(type).search_by_keywords(words:, commentable_type:)
    end
  end

  def self.result_for_comments(document_type, word)
    [document_type, :comments].flat_map do |type|
      result_for(type, word, commentable_type: model_name(document_type))
    end.sort_by(&:updated_at).reverse
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

  def self.delete_comment_of_talk_and_inquiry!(searchables)
    searchables.reject do |searchable|
      searchable.instance_of?(Comment) && searchable.commentable.instance_of?(Talk) && searchable.commentable.instance_of?(Inquiry)
    end
  end

  def self.highlight_word(text, word)
    return '' unless text.present? && word.present?

    sanitized_word = Regexp.escape(word)
    text.gsub(/(#{sanitized_word})/i, '<strong class="matched_word">\1</strong>')
  end
end
