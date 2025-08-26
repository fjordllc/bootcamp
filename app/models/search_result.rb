# frozen_string_literal: true

class SearchResult
  include SearchHelper
  include ActionView::Helpers::SanitizeHelper
  include ERB::Util
  include SearchResultAttributes

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
    @user_id = determine_user_id(searchable)

    if @user_id && (u = @users_by_id_map[@user_id])
      @login_name = u.login_name
      @primary_role = u.primary_role
    else
      @login_name = searchable.respond_to?(:login_name) ? searchable.login_name : nil
      @primary_role = nil
    end

    @commentable_user = determine_commentable_user(searchable)
  end

  def initialize_metadata_attributes(searchable)
    @formatted_updated_at =
      searchable.respond_to?(:formatted_updated_at) ? searchable.formatted_updated_at : searchable.updated_at.strftime('%Y年%m月%d日 %H:%M')
    @label = fetch_label(searchable)
    @commentable_type = fetch_commentable_type(searchable)
  end
end
