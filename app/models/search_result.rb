# frozen_string_literal: true

class SearchResult
  include SearchHelper

  attr_accessor :url, :title, :summary, :formatted_summary, :user_id,
                :login_name, :formatted_updated_at, :model_name, :label,
                :wip, :commentable_user, :commentable_type, :primary_role, :current_user

  def initialize(searchable, word, current_user)
    @current_user = current_user
    @url = searchable_url(searchable)
    @title = fetch_title(searchable)
    @summary = searchable_summary(filtered_message(searchable), word)
    @formatted_summary = highlight_word(@summary, word)
    @user_id = searchable.is_a?(User) ? searchable.id : searchable.try(:user_id)
    @login_name = fetch_login_name(searchable)
    @formatted_updated_at = searchable.respond_to?(:formatted_updated_at) ? searchable.formatted_updated_at : searchable.updated_at.strftime('%Y年%m月%d日 %H:%M')
    @model_name = searchable.class.name.underscore
    @label = fetch_label(searchable)
    @wip = searchable.try(:wip)
    @commentable_user = fetch_commentable_user(searchable)
    @commentable_type = I18n.t("activerecord.models.#{searchable.try(:commentable)&.try(:model_name)&.name&.underscore}", default: '')
    @primary_role = created_user(searchable)&.primary_role
  end

  private

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

    words = word.split(/[[:blank:]]+/).reject(&:blank?)
    words.each do |w|
      text = text.gsub(/(#{Regexp.escape(w)})/i, '<strong class="matched_word">\1</strong>')
    end

    text
  end
end
