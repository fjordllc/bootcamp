# frozen_string_literal: true

class SearchResult
  include SearchResultDecorator

  attr_reader :resource, :keyword, :current_user
  attr_accessor :url, :title, :summary, :user_id,
                :login_name, :model_name, :label,
                :wip, :commentable_user, :commentable_type, :primary_role

  delegate :id, :class, :updated_at, to: :resource
  
  # リソースのメソッドを委譲（method_missingを使って動的に委譲）
  def method_missing(method_name, *args, &block)
    if resource.respond_to?(method_name)
      resource.send(method_name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    resource.respond_to?(method_name, include_private) || super
  end

  def initialize(resource, keyword, current_user)
    @resource = resource
    @keyword = keyword
    @current_user = current_user
    initialize_attributes
  end

  # テストで期待されるtypeメソッドを追加
  def type
    model_name
  end

  private

  def initialize_attributes
    initialize_basic_attributes
    initialize_content_attributes
    initialize_user_attributes
    initialize_metadata_attributes
  end

  def initialize_basic_attributes
    @url = url
    @title = if resource.is_a?(Answer) || resource.is_a?(CorrectAnswer)
               resource.question&.title
             else
               (resource.is_a?(User) ? resource.login_name : resource.try(:title) || '')
             end
    @model_name = resource.class.name.underscore
    @wip = resource.try(:wip)
  end

  def initialize_content_attributes
    @summary = generate_summary
  end

  def initialize_user_attributes
    @user_id = resource.is_a?(User) ? resource.id : resource.try(:user_id)
    @login_name = fetch_login_name
    @commentable_user = fetch_commentable_user
    @primary_role = created_user&.primary_role
  end

  def initialize_metadata_attributes
    @label = if resource.is_a?(User)
               resource.avatar_url
             else
               Searcher::SEARCH_CONFIGS.find do |_, v|
                 v[:model] == resource.class
               end&.last&.dig(:label) || resource.try(:label) || resource.class.model_name.human
             end
    @commentable_type = resource.try(:commentable) ? I18n.t("activerecord.models.#{resource.commentable.model_name.name.underscore}", default: '') : ''
  end

  def fetch_login_name
    User.find_by(id: resource.try(:user_id))&.login_name
  end

  def fetch_commentable_user
    return resource.question&.user if resource.is_a?(Answer) || resource.is_a?(CorrectAnswer)

    resource.try(:commentable)&.try(:user)
  end

  def generate_summary
    content = filtered_content
    return '' if content.nil? || content.blank?

    return process_special_case(content, keyword) if content.is_a?(String) && content.include?('|') && !content.include?('```')

    plain_content = md2plain_text(content)
    result = find_match_in_text(plain_content, keyword)
    result || ''
  end
end
