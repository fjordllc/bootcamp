# frozen_string_literal: true

require 'application_system_test_case'

module Bookmarks
  class AnnouncementTest < ApplicationSystemTestCase
    setup do
      @announcement = announcements(:announcement1)
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
  end
end
