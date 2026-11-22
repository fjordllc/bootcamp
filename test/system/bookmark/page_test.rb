# frozen_string_literal: true

require 'application_system_test_case'

class Bookmark::PageTest < ApplicationSystemTestCase
  setup do
    @page = pages(:page1)
  end

  test 'bookmark page' do
    visit_with_auth "/pages/#{@page.id}", 'komagata'
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'

    visit '/current_user/bookmarks'
    assert_text @page.title
  end
end
