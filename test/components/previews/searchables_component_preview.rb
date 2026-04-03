# frozen_string_literal: true

class SearchablesComponentPreview < ViewComponent::Preview
  def default
    searchables = [mock_searchable(:report, 1), mock_searchable(:page, 2)]
    users = { 1 => mock_user('yamada'), 2 => mock_user('tanaka') }

    render(SearchablesComponent.new(searchables: searchables, users: users, word: 'Ruby', talks: {}))
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

  SEARCHABLE_DATA = {
    report: { title: '学習日報: Rubyの基礎', label: '日報', url: '/reports/1' },
    page: { title: 'Ruby入門ガイド', label: 'ページ', url: '/pages/1' }
  }.freeze

  def mock_searchable(type, user_id)
    data = SEARCHABLE_DATA[type]
    OpenStruct.new(
      search_model_name: type.to_s, search_user_id: user_id,
      search_title: data[:title], search_label: data[:label], search_url: data[:url],
      updated_at: rand(1..7).days.ago, class: OpenStruct.new(name: type.to_s.classify)
    )
  end

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
