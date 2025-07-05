# frozen_string_literal: true

class SearchResult
  include SearchHelper

  attr_accessor :url, :title, :summary, :formatted_summary, :user_id,
                :login_name, :formatted_updated_at, :model_name, :label,
                :wip, :commentable_user, :commentable_type, :primary_role, :current_user

  def initialize(searchable, word, current_user)
    @current_user = current_user
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
    @user_id = searchable.is_a?(User) ? searchable.id : searchable.try(:user_id)
    @login_name = fetch_login_name(searchable)
    @commentable_user = fetch_commentable_user(searchable)
    @primary_role = created_user(searchable)&.primary_role
  end

  def initialize_metadata_attributes(searchable)
    @formatted_updated_at = searchable.respond_to?(:formatted_updated_at) ? searchable.formatted_updated_at : searchable.updated_at.strftime('%Y年%m月%d日 %H:%M')
    @label = fetch_label(searchable)
    @commentable_type = fetch_commentable_type(searchable)
  end

  def fetch_title(searchable)
    return searchable.question&.title if searchable.is_a?(Answer)
    return searchable.login_name if searchable.is_a?(User)

    searchable.try(:title)
  end

  def fetch_login_name(searchable)
    User.find_by(id: searchable.try(:user_id))&.login_name
  end

  def fetch_commentable_user(searchable)
    return searchable.question&.user if searchable.is_a?(Answer) || searchable.is_a?(CorrectAnswer)

    searchable.try(:commentable)&.try(:user)
  end

  def fetch_label(searchable)
    searchable.is_a?(User) ? searchable.avatar_url : searchable.try(:label)
  end

  def highlight_word(text, word)
    return unless text
    return text if word.blank?

    escaped_text = ERB::Util.html_escape(text)
    words = word.split(/[[:blank:]]+/).reject(&:blank?)
    words.each do |w|
      escaped_text = escaped_text.gsub(/(#{Regexp.escape(w)})/i, '<strong class="matched_word">\1</strong>')
    end

    escaped_text.html_safe
  end

  def fetch_commentable_type(searchable)
    return '' unless searchable.try(:commentable)
    model_name = searchable.commentable.model_name.name.underscore
    I18n.t("activerecord.models.#{model_name}", default: '')
  rescue => e
    Rails.logger.warn "Failed to fetch commentable type: #{e.message}"
    ''
  end
end
