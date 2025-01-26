# frozen_string_literal: true

class SearchResult
  include SearchHelper

  attr_accessor :url, :title, :summary, :formatted_summary, :user_id,
                :login_name, :formatted_updated_at, :model_name, :label,
                :wip, :commentable_user, :commentable_type, :primary_role

  def initialize(searchable, word, current_user)
    @url = searchable_url(searchable)
    @title = Searcher.fetch_title(searchable)
    @summary = filtered_message(searchable, current_user)
    @formatted_summary = Searcher.highlight_word(@summary, word)
    @user_id = searchable.is_a?(User) ? searchable.id : searchable.try(:user_id)
    @login_name = Searcher.fetch_login_name(searchable)
    @formatted_updated_at = searchable.respond_to?(:formatted_updated_at) ? searchable.formatted_updated_at : searchable.updated_at.strftime('%Y年%m月%d日 %H:%M')
    @model_name = searchable.class.name.underscore
    @label = Searcher.fetch_label(searchable)
    @wip = searchable.try(:wip)
    @commentable_user = Searcher.fetch_commentable_user(searchable)
    @commentable_type = I18n.t("activerecord.models.#{searchable.try(:commentable)&.try(:model_name)&.name&.underscore}", default: '')
    @primary_role = created_user(searchable)&.primary_role
  end
end
