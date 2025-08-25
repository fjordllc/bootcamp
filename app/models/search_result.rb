# frozen_string_literal: true

class SearchResult
  include SearchHelper
  include ActionView::Helpers::SanitizeHelper
  include ERB::Util

  attr_accessor :url, :title, :summary, :formatted_summary, :user_id,
                :login_name, :formatted_updated_at, :model_name, :label,
                :wip, :commentable_user, :commentable_type, :primary_role, :current_user

  attr_reader :users_by_id_map

  def initialize(searchable, word, current_user, users_by_id: {})
    @current_user = current_user
    @users_by_id_map = users_by_id || {}

    initialize_basic_attributes(searchable)
    initialize_content_attributes(searchable, word)
    initialize_user_attributes(searchable)
    initialize_metadata_attributes(searchable)
  end

  private

  def initialize_basic_attributes(searchable)
    @url = searchable_url(searchable)
    @title = fetch_title(searchable)
    @model_name = searchable.class.name.underscore
    @wip = searchable.try(:wip)
  end

  def initialize_content_attributes(searchable, word)
    @summary = searchable_summary(filtered_message(searchable), word)
    @formatted_summary = highlight_word(@summary, word)
  end

  def initialize_user_attributes(searchable)
    @user_id = if searchable.is_a?(User)
                 searchable.id
               elsif searchable.respond_to?(:user_id) && searchable.user_id.present?
                 searchable.user_id
               elsif searchable.respond_to?(:user) && searchable.user.present?
                 searchable.user.id
               end

    if @user_id && (u = @users_by_id_map[@user_id])
      @login_name = u.login_name
      @primary_role = u.primary_role
    else
      @login_name = searchable.respond_to?(:login_name) ? searchable.login_name : nil
      @primary_role = nil
    end
  end

  def initialize_metadata_attributes(searchable)
    @formatted_updated_at =
      searchable.respond_to?(:formatted_updated_at) ? searchable.formatted_updated_at : searchable.updated_at.strftime('%Y年%m月%d日 %H:%M')
    @label = fetch_label(searchable)
    @commentable_type = fetch_commentable_type(searchable)
  end

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
end
