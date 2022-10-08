# frozen_string_literal: true

require 'application_system_test_case'

class API::BookmarkTest < ApplicationSystemTestCase
  test 'turn on/off bookmark button on report' do
    visit_with_auth "/reports/#{reports(:report74).id}", 'kimura'
    find('#bookmark-button.is-inactive').click
    assert_text 'Bookmark中'
    assert_text 'Bookmarkしました！'
    find('#bookmark-button.is-active').click
    assert_text 'Bookmark'
    assert_text 'Bookmarkを削除しました'
  end

  test 'turn on/off bookmark button on product' do
    visit_with_auth "/products/#{products(:product70).id}", 'kimura'
    find('#bookmark-button.is-inactive').click
    assert_text 'Bookmark中'
    assert_text 'Bookmarkしました！'
    find('#bookmark-button.is-active').click
    assert_text 'Bookmark'
    assert_text 'Bookmarkを削除しました'
  end

  test 'turn on/off bookmark button on question' do
    visit_with_auth "/questions/#{questions(:question15).id}", 'kimura'
    find('#bookmark-button.is-inactive').click
    assert_text 'Bookmark中'
    assert_text 'Bookmarkしました！'
    find('#bookmark-button.is-active').click
    assert_text 'Bookmark'
    assert_text 'Bookmarkを削除しました'
  end
end
