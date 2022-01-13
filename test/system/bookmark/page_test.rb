# frozen_string_literal: true

require 'application_system_test_case'

class Bookmark::PageTest < ApplicationSystemTestCase
  setup do
    @page = pages(:page1)
  end

  test 'show page bookmark on lists' do
    visit_with_auth '/current_user/bookmarks', 'kimura'
    assert_equal 'ブックマーク一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_text @page.title
  end

  test 'show active button when bookmarked page' do
    visit_with_auth "/pages/#{@page.id}", 'kimura'
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
  end

  test 'show inactive button when not bookmarked page' do
    visit_with_auth "/pages/#{@page.id}", 'komagata'
    wait_for_vuejs
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
  end

  test 'bookmark page' do
    visit_with_auth "/pages/#{@page.id}", 'komagata'
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'

    visit '/current_user/bookmarks'
    assert_text @page.title
  end

  test 'unbookmark page' do
    visit_with_auth "/pages/#{@page.id}", 'kimura'
    wait_for_vuejs
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'

    visit '/current_user/bookmarks'
    assert_no_text @page.title
  end
end
