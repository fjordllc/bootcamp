# frozen_string_literal: true

require 'application_system_test_case'

class BookmarksTest < ApplicationSystemTestCase
  setup do
    @report = reports(:report1)
    @question = questions(:question1)
    @movie = movies(:movie1)
  end

  test 'show my bookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'komagata'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-active'
    assert_no_selector '[data-bookmark-button].is-inactive'
    assert_selector '[data-bookmark-button]', text: 'Bookmark中'
  end

  test 'show not bookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'machida'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-inactive'
    assert_no_selector '[data-bookmark-button].is-active'
    assert_selector '[data-bookmark-button]', text: 'Bookmark'
  end

  test 'bookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'machida'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-inactive', text: 'Bookmark'
    find('[data-bookmark-button]').click
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-active'
    assert_no_selector '[data-bookmark-button].is-inactive'
    assert_selector '[data-bookmark-button]', text: 'Bookmark中'

    visit '/current_user/bookmarks'
    assert_text @report.title
  end

  test 'unbookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'komagata'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-active', text: 'Bookmark中'
    find('[data-bookmark-button]').click
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-inactive'
    assert_no_selector '[data-bookmark-button].is-active'
    assert_selector '[data-bookmark-button]', text: 'Bookmark'

    visit '/current_user/bookmarks'
    assert_no_text @report.title
  end

  test 'show question bookmark on lists' do
    visit_with_auth '/current_user/bookmarks', 'kimura'
    assert_text @question.title
  end

  test 'show active button when bookmarked question' do
    visit_with_auth "/questions/#{@question.id}", 'kimura'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-active'
    assert_no_selector '[data-bookmark-button].is-inactive'
    assert_selector '[data-bookmark-button]', text: 'Bookmark中'
  end

  test 'show inactive button when not bookmarked question' do
    visit_with_auth "/questions/#{@question.id}", 'hajime'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-inactive'
    assert_no_selector '[data-bookmark-button].is-active'
    assert_selector '[data-bookmark-button]', text: 'Bookmark'
  end

  test 'bookmark question' do
    visit_with_auth "/questions/#{@question.id}", 'hatsuno'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-inactive', text: 'Bookmark'
    find('[data-bookmark-button]').click
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-active'
    assert_no_selector '[data-bookmark-button].is-inactive'
    assert_selector '[data-bookmark-button]', text: 'Bookmark中'

    visit '/current_user/bookmarks'
    assert_text @question.title
  end

  test 'unbookmark question' do
    visit_with_auth "/questions/#{@question.id}", 'kimura'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-active', text: 'Bookmark中'
    find('[data-bookmark-button]').click
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-inactive'
    assert_no_selector '[data-bookmark-button].is-active'
    assert_selector '[data-bookmark-button]', text: 'Bookmark'

    visit '/current_user/bookmarks'
    assert_no_text @question.title
  end

  test 'bookmark movie' do
    visit_with_auth "/movies/#{@movie.id}", 'hatsuno'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-inactive', text: 'Bookmark'
    find('[data-bookmark-button]').click
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-active'
    assert_no_selector '[data-bookmark-button].is-inactive'
    assert_selector '[data-bookmark-button]', text: 'Bookmark中'

    visit '/current_user/bookmarks'
    assert_text @movie.title
  end

  test 'unbookmark movie' do
    visit_with_auth "/movies/#{@movie.id}", 'kimura'
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-active', text: 'Bookmark中'
    find('[data-bookmark-button]').click
    wait_for_bookmark_button_loading
    assert_selector '[data-bookmark-button].is-inactive'
    assert_no_selector '[data-bookmark-button].is-active'
    assert_selector '[data-bookmark-button]', text: 'Bookmark'

    visit '/current_user/bookmarks'
    assert_no_text @movie.title
  end
end
