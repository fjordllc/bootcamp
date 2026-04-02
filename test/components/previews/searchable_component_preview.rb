# frozen_string_literal: true

class SearchableComponentPreview < ViewComponent::Preview
  def default
    resource = OpenStruct.new(
      search_model_name: 'report',
      search_user_id: 1,
      search_title: '学習日報: Rubyの基礎を学んだ',
      search_label: '日報',
      search_url: '/reports/1',
      updated_at: 1.day.ago,
      wip: false,
      class: OpenStruct.new(name: 'Report')
    )
    users = { 1 => mock_user('yamada') }
    talks = {}

    render(SearchableComponent.new(
      resource: resource,
      users: users,
      word: 'Ruby',
      talks: talks
    ))
  end

  def comment_result
    resource = OpenStruct.new(
      search_model_name: 'comment',
      search_user_id: 1,
      search_commentable_user: 'tanaka',
      search_commentable_type: 'Report',
      search_title: 'コメント: いい学習ですね！',
      search_label: 'コメント',
      search_url: '/reports/1#comment_1',
      updated_at: 2.hours.ago,
      class: OpenStruct.new(name: 'Comment')
    )
    users = { 1 => mock_user('yamada') }
    talks = {}

    render(SearchableComponent.new(
      resource: resource,
      users: users,
      word: '学習',
      talks: talks
    ))
  end

  def user_result
    resource = OpenStruct.new(
      search_model_name: 'user',
      search_user_id: 1,
      search_title: 'yamada',
      search_label: 'ユーザー',
      search_url: '/users/yamada',
      updated_at: 1.week.ago,
      login_name: 'yamada',
      class: OpenStruct.new(name: 'User')
    )
    users = { 1 => mock_user('yamada') }
    talks = { 1 => OpenStruct.new(id: 1) }

    render(SearchableComponent.new(
      resource: resource,
      users: users,
      word: 'yamada',
      talks: talks
    ))
  end

  private

  def mock_user(name)
    OpenStruct.new(
      id: 1,
      login_name: name,
      name: name,
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: name
    )
  end
end
