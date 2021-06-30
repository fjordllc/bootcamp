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
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
  end

  test 'show not bookmark report' do
    login_user 'machida', 'testtest'
    visit "/reports/#{@report.id}"
    wait_for_vuejs
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
  end

  test 'bookmark' do
    login_user 'machida', 'testtest'
    visit "/reports/#{@report.id}"
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'

    visit '/bookmarks'
    assert_text @report.title
  end

  test 'unbookmark' do
    login_user 'komagata', 'testtest'
    visit "/reports/#{@report.id}"
    wait_for_vuejs
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'

    visit '/bookmarks'
    assert_no_text @report.title
  end
end
