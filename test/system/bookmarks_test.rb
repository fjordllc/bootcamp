# frozen_string_literal: true

require 'application_system_test_case'

class BookmarksTest < ApplicationSystemTestCase
  setup do
    @report = reports(:report1)
    @question = questions(:question1)
  end

  test 'show my bookmark lists' do
    visit_with_auth '/bookmarks', 'komagata'
    assert_text 'ブックマーク一覧'
    assert_text @report.title
  end

  test 'show question bookmark on lists' do
    visit_with_auth '/bookmarks', 'kimura'
    assert_text 'ブックマーク一覧'
    assert_text @question.title
  end

  test 'show my bookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'komagata'
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
  end

  test 'show not bookmark report' do
    visit_with_auth "/reports/#{@report.id}", 'machida'
    wait_for_vuejs
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
  end

  test 'show active button when bookmarked question' do
    visit_with_auth "/questions/#{@question.id}", 'kimura'
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
  end

  test 'show inactive button when not bookmarked question' do
    visit_with_auth "/questions/#{@question.id}", 'hajime'
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
  end

  test 'bookmark' do
    visit_with_auth "/reports/#{@report.id}", 'machida'
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'

    visit '/bookmarks'
    assert_text @report.title
  end

  test 'unbookmark' do
    visit_with_auth "/reports/#{@report.id}", 'komagata'
    wait_for_vuejs
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'

    visit '/bookmarks'
    assert_no_text @report.title
  end

  test 'bookmark question' do
    visit_with_auth "/questions/#{@question.id}", 'hatsuno'
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'

    visit '/bookmarks'
    assert_text @question.title
  end

  test 'unbookmark question' do
    visit_with_auth "/questions/#{@question.id}", 'kimura'
    wait_for_vuejs
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'

    visit '/bookmarks'
    assert_no_text @question.title
  end
end
