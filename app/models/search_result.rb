# frozen_string_literal: true

class SearchResult
  attr_accessor :url, :title, :summary, :formatted_summary, :user_id,
                :login_name, :formatted_updated_at, :model_name, :label,
                :wip, :commentable_user, :commentable_type, :primary_role

  def initialize(searchable, word)
    @url = searchable.try(:url)
    @title = Searcher.fetch_title(searchable)
    @summary = searchable.try(:summary)
    @formatted_summary = searchable.formatted_summary(word)
    @user_id = searchable.is_a?(User) ? searchable.id : searchable.try(:user_id)
    @login_name = Searcher.fetch_login_name(searchable)
    @formatted_updated_at = searchable.formatted_updated_at
    @model_name = searchable.class.name.underscore
    @label = Searcher.fetch_label(searchable)
    @wip = searchable.try(:wip)
    @commentable_user = Searcher.fetch_commentable_user(searchable)
    @commentable_type = I18n.t("activerecord.models.#{searchable.try(:commentable)&.try(:model_name)&.name&.underscore}", default: '')
    @primary_role = searchable.primary_role
  end
end
