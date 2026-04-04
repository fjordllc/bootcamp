# frozen_string_literal: true

class SearchableComponentPreview < ViewComponent::Preview
  include PreviewHelper

  def default
    resource = OpenStruct.new(
      search_model_name: 'report', search_user_id: 1,
      search_title: '学習日報: Rubyの基礎', search_label: '日報',
      search_url: '/reports/1', updated_at: 1.day.ago, wip: false,
      class: OpenStruct.new(name: 'Report')
    )
    users = { 1 => build_mock_user }
    talks = {}

    render(SearchableComponent.new(resource: resource, users: users, word: 'Ruby', talks: talks))
  end

  def user_result
    resource = OpenStruct.new(
      search_model_name: 'user', search_user_id: 1,
      search_title: 'yamada', search_label: 'ユーザー',
      search_url: '/users/yamada', updated_at: 1.week.ago, login_name: 'yamada',
      class: OpenStruct.new(name: 'User')
    )
    users = { 1 => build_mock_user }
    talks = { 1 => OpenStruct.new(id: 1) }

    render(SearchableComponent.new(resource: resource, users: users, word: 'yamada', talks: talks))
  end
end
