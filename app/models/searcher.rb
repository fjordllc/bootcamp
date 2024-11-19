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

      OpenStruct.new(
        url: searchable.try(:url),
        title: searchable.try(:title),
        summary: searchable.try(:summary),
        formatted_summary: searchable.formatted_summary(word),
        user_id: searchable.try(:user_id),
        login_name: searchable.try(:login_name),
        formatted_updated_at: searchable.formatted_updated_at,
        model_name: searchable.class.name.underscore,
        label: searchable.label,
        wip: searchable.try(:wip),
        commentable_user: searchable.try(:commentable)&.try(:user),
        commentable_type: I18n.t("activerecord.models.#{searchable.try(:commentable)&.try(:model_name)&.name&.underscore}", default: '')
      )
    end
  end

  def self.result_for_all(word)
    AVAILABLE_TYPES
      .flat_map { |type| result_for(type, word) }
      .sort_by(&:updated_at)
      .reverse
  end

  def self.result_for(type, word, commentable_type: nil)
    raise ArgumentError "#{type} is not available type" unless type.in?(AVAILABLE_TYPES)

    if commentable?(type)
      model(type).search_by_keywords(word:, commentable_type:) +
        Comment.search_by_keywords(word:, commentable_type: model_name(type))
    else
      model(type).search_by_keywords(word:, commentable_type:)
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
