# frozen_string_literal: true

class SearchablesComponentPreview < ViewComponent::Preview
  include PreviewHelper

  SEARCHABLE_DATA = {
    report: { title: '学習日報: Rubyの基礎', label: '日報', url: '/reports/1' },
    page: { title: 'Ruby入門ガイド', label: 'ページ', url: '/pages/1' }
  }.freeze

  def default
    searchables = [mock_searchable(:report, 1), mock_searchable(:page, 2)]
    users = { 1 => build_mock_user, 2 => build_mock_user(id: 2, login_name: 'tanaka', name: 'tanaka', icon_title: 'tanaka') }

    render(SearchablesComponent.new(searchables: searchables, users: users, word: 'Ruby', talks: {}))
  end

  def empty_results
    render(SearchablesComponent.new(searchables: [], users: {}, word: 'notfound', talks: {}))
  end

  private

  def mock_searchable(type, user_id)
    data = SEARCHABLE_DATA[type]
    OpenStruct.new(
      search_model_name: type.to_s, search_user_id: user_id,
      search_title: data[:title], search_label: data[:label], search_url: data[:url],
      updated_at: rand(1..7).days.ago, class: OpenStruct.new(name: type.to_s.classify)
    )
  end
end
