# frozen_string_literal: true

require 'application_system_test_case'

class HomeBookmarksTest < ApplicationSystemTestCase
  test 'show the five latest bookmarks on dashboard' do
    visit_with_auth "/questions/#{questions(:question1).id}", 'machida'
    find('#bookmark-button').click
    visit "/pages/#{pages(:page1).id}"
    find('#bookmark-button').click
    visit "/talks/#{talks(:talk1).id}"
    find('#bookmark-button').click
    reports = %i[report68 report69 report70]
    reports.each do |report|
      visit "/reports/#{reports(report).id}"
      find('#bookmark-button').click
    end
    assert_text 'Bookmarkしました！'

    visit '/'
    assert_text '最新のブックマーク'
    find_link pages(:page1).title
    assert_text I18n.l pages(:page1).created_at, format: :long
    user = talks(:talk1).user
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    find_link "#{decorated_user.long_name} さんの相談部屋"
    reports.each do |report|
      find_link reports(report).title
      assert_text I18n.l reports(report).reported_on, format: :long
    end
  end

  test 'not show bookmarks on dashboard when the user has no bookmarks' do
    visit_with_auth '/', 'machida'
    assert_current_path '/?_login_name=machida'
    assert_no_text '最新のブックマーク'
  end

  test 'delete bookmark for latest bookmarks on dashboard' do
    visit_with_auth '/', 'kimura'

    reports = %i[report68 report69 report70 report71]
    reports.each do |report|
      visit "/reports/#{reports(report).id}"
      find('#bookmark-button').click
    end
    assert_text 'Bookmarkしました！'

    visit '/'
    first('.spec-bookmark-edit').click
    first('.js-bookmark-delete-button').click
    assert_text 'ブックマークを削除しました。'
    assert_no_text '名前の長いメンター用'
  end
end
