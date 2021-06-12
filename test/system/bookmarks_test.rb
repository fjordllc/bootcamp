# frozen_string_literal: true

require 'application_system_test_case'

class BookmarksTest < ApplicationSystemTestCase
  setup do
    @report = reports(:report1)
  end

  test 'show my bookmark lists' do
    login_user 'komagata', 'testtest'
    visit '/bookmarks'
    assert_text 'ブックマーク一覧'
    assert_text @report.title
  end

  test 'show my bookmark report' do
    login_user 'komagata', 'testtest'
    visit "/reports/#{@report.id}"
    assert_text 'bookmark解除'
    assert_no_text 'bookmarkする'
  end

  test 'show not bookmark report' do
    login_user 'machida', 'testtest'
    visit "/reports/#{@report.id}"
    assert_text 'bookmarkする'
    assert_no_text 'bookmark解除'
  end

  test 'bookmark' do
    login_user 'machida', 'testtest'
    visit "/reports/#{@report.id}"
    find('#bookmark-button').click
    wait_for_vuejs
    assert_text 'bookmark解除'

    visit '/bookmarks'
    assert_text @report.title
  end

  test 'unbookmark' do
    login_user 'komagata', 'testtest'
    visit "/reports/#{@report.id}"
    wait_for_vuejs
    find('#bookmark-button').click
    assert_text 'bookmarkする'

    visit '/bookmarks'
    assert_no_text @report.title
  end
end
