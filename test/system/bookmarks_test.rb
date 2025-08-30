# frozen_string_literal: true

require 'application_system_test_case'

class BookmarksTest < ApplicationSystemTestCase
  setup do
    @report = reports(:report1)
    @question = questions(:question1)
    @announcement = announcements(:announcement1)
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

  test 'bookmark' do
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

  test 'unbookmark' do
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

  test 'show question bookmark on lists' do
    visit_with_auth '/current_user/bookmarks', 'kimura'
    assert_text @question.title
  end

  test 'show active button when bookmarked question' do
    visit_with_auth "/questions/#{@question.id}", 'kimura'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
    assert_selector '#bookmark-button', text: 'Bookmark中'
  end

  test 'show inactive button when not bookmarked question' do
    visit_with_auth "/questions/#{@question.id}", 'hajime'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
    assert_selector '#bookmark-button', text: 'Bookmark'
  end

  test 'bookmark question' do
    visit_with_auth "/questions/#{@question.id}", 'hatsuno'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive', text: 'Bookmark'
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
    assert_selector '#bookmark-button', text: 'Bookmark中'

    visit '/current_user/bookmarks'
    assert_text @question.title
  end

  test 'unbookmark question' do
    visit_with_auth "/questions/#{@question.id}", 'kimura'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active', text: 'Bookmark中'
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
    assert_selector '#bookmark-button', text: 'Bookmark'

    visit '/current_user/bookmarks'
    assert_no_text @question.title
  end

  test 'bookmark announcement' do
    visit_with_auth "/announcements/#{@announcement.id}", 'hatsuno'
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive', text: 'Bookmark'
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
    assert_selector '#bookmark-button', text: 'Bookmark中'

    visit '/current_user/bookmarks'
    assert_text @announcement.title
  end

  test 'unbookmark announcement' do
    user = users(:kimura)
    user.bookmarks.create!(bookmarkable: @announcement)

    visit_with_auth "/announcements/#{@announcement.id}", user.login_name
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active', text: 'Bookmark中'
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
    assert_selector '#bookmark-button', text: 'Bookmark'

    visit '/current_user/bookmarks'
    assert_no_text @announcement.title
  end
end
