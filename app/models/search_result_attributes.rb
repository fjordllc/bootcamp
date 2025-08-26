# frozen_string_literal: true

module SearchResultAttributes
  private

  def fetch_title(searchable)
    return searchable.question&.title if searchable.is_a?(Answer)
    return searchable.login_name if searchable.is_a?(User)

    if searchable.is_a?(Comment)
      commentable = searchable.commentable
      return title_from_commentable(commentable)
    end

    if searchable.is_a?(Searcher::SearchRow) && searchable.record_type == 'comments'
      commentable = searchable.commentable
      return title_from_commentable(commentable)
    end

    searchable.try(:title)
  end

  def fetch_login_name(searchable)
    uid = searchable.try(:user_id)
    return nil if uid.blank?

    @users_by_id_map[uid]&.login_name
  end

  def fetch_label(searchable)
    return searchable.avatar_url if searchable.is_a?(User)

    if searchable.is_a?(Searcher::SearchRow) && searchable.record_type == 'comments'
      searchable.comment_label
    else
      searchable.try(:label)
    end
  end

  def fetch_commentable_user(searchable)
    return searchable.question&.user if searchable.is_a?(Answer) || searchable.is_a?(CorrectAnswer)

    searchable.try(:commentable)&.try(:user)
  end

  def highlight_word(text, word)
    return unless text
    return text if word.blank?

    escaped_text = ERB::Util.html_escape(text)
    words = word.split(/[[:blank:]]+/).reject(&:blank?)
    highlighted_fragments = words.reduce(escaped_text) do |text_fragment, w|
      text_fragment.gsub(/(#{Regexp.escape(w)})/i, '<strong class="matched_word">\1</strong>')
    end

    sanitize(highlighted_fragments, tags: %w[strong], attributes: %w[class])
  end

  def fetch_commentable_type(searchable)
    return '' unless searchable.try(:commentable)

    model_name = searchable.commentable.model_name.name.underscore
    I18n.t("activerecord.models.#{model_name}", default: '')
  rescue StandardError => e
    Rails.logger.warn "Failed to fetch commentable type: #{e.message}"
    ''
  end

  def title_from_commentable(commentable)
    return nil unless commentable

    case commentable
    when Product
      commentable.practice&.title.presence
    else
      commentable.title.presence
    end
  end

  def determine_user_id(searchable)
    return searchable.id if searchable.is_a?(User)
    return searchable.user_id if searchable.respond_to?(:user_id) && searchable.user_id.present?
    return searchable.user.id if searchable.respond_to?(:user) && searchable.user.present?

    nil
  end

  def determine_commentable_user(searchable)
    return searchable.try(:question)&.try(:user) if searchable.is_a?(Answer) || searchable.is_a?(CorrectAnswer)

    return searchable.commentable.try(:user) if searchable.respond_to?(:commentable) && searchable.commentable.present?

    nil
  end
end
