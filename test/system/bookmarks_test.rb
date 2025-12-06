# frozen_string_literal: true

require 'application_system_test_case'

class BookmarksTest < ApplicationSystemTestCase
  setup do
    @report = reports(:report1)
  end

  test 'show my bookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'komagata'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
    assert_selector '#bookmark-button', text: 'Bookmark中'
  end

  test 'show not bookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'machida'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
    assert_selector '#bookmark-button', text: 'Bookmark'
  end

  test 'bookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'machida'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive', text: 'Bookmark'
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
    assert_selector '#bookmark-button', text: 'Bookmark中'

    visit '/current_user/bookmarks'
    assert_text @report.title
  end

  test 'unbookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'komagata'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active', text: 'Bookmark中'
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
    assert_selector '#bookmark-button', text: 'Bookmark'

    visit '/current_user/bookmarks'
    assert_no_text @report.title
  end
end
