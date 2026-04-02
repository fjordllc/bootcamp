# frozen_string_literal: true

class SearchablesComponentPreview < ViewComponent::Preview
  def default
    searchables = [
      OpenStruct.new(
        search_model_name: 'report',
        search_user_id: 1,
        search_title: '学習日報: Rubyの基礎',
        search_label: '日報',
        search_url: '/reports/1',
        updated_at: 1.day.ago,
        wip: false,
        class: OpenStruct.new(name: 'Report')
      ),
      OpenStruct.new(
        search_model_name: 'page',
        search_user_id: 2,
        search_title: 'Ruby入門ガイド',
        search_label: 'ページ',
        search_url: '/pages/1',
        updated_at: 3.days.ago,
        class: OpenStruct.new(name: 'Page')
      )
    ]
    users = {
      1 => mock_user('yamada'),
      2 => mock_user('tanaka')
    }

    render(SearchablesComponent.new(
      searchables: searchables,
      users: users,
      word: 'Ruby',
      talks: {}
    ))
  end

  def empty_results
    render(SearchablesComponent.new(
      searchables: [],
      users: {},
      word: 'notfound',
      talks: {}
    ))
  end

  private

  def mock_user(name)
    OpenStruct.new(
      id: rand(1..100),
      login_name: name,
      name: name,
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: name
    )
  end
end
