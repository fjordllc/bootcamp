# frozen_string_literal: true

class SearchableComponent < ViewComponent::Base
  def initialize(resource:, users:, word:, talks:)
    @resource = resource
    @users = users
    @word = word
    @talks = talks
  end

  def resource_user
    @resource_user ||= users[resource.search_user_id]
  end

  def talk
    @talk ||= talks[resource_user&.id]
  end

  def comment_meta_info
    return unless resource.search_model_name == 'comment'

    safe_join([
                '(',
                link_to(resource.search_commentable_user&.login_name, "/users/#{resource.search_commentable_user&.id}", class: 'a-user-name'),
                " #{resource.search_commentable_type})"
              ], ' ')
  end

  def answer_meta_info
    return unless resource.search_model_name.in?(%w[answer correct_answer])

    safe_join([
                '(',
                link_to(resource.search_commentable_user&.login_name, "/users/#{resource.search_commentable_user&.id}", class: 'a-user-name'),
                ' Q&A)'
              ], ' ')
  end

  def search_title_text
    resource.search_title.presence || resource.try(:login_name)
  end

  private

  attr_reader :resource, :users, :word, :talks
end
