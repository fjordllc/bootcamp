# frozen_string_literal: true

require 'application_system_test_case'

module Announcements
  class CrudTest < ApplicationSystemTestCase
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'show link to create new announcement when user is admin' do
      visit_with_auth '/announcements', 'komagata'
      assert_text 'お知らせ作成'
    end

    test "show link to create new announcement when user isn't admin" do
      visit_with_auth '/announcements', 'kimura'
      assert_text 'お知らせ作成'
    end

    test 'general user can create announcement' do
      visit_with_auth '/announcements', 'kimura'
      click_link 'お知らせ作成'
      assert has_button? '作成'
    end

    test 'announcement has a copy form when user is admin' do
      visit_with_auth "/announcements/#{announcements(:announcement4).id}", 'komagata'
      click_link 'コピー'

      assert_text 'お知らせをコピーしました。'
    end

    test 'announcement has a copy form when user is author' do
      visit_with_auth "/announcements/#{announcements(:announcement4).id}", 'kimura'
      click_link 'コピー'

      assert_text 'お知らせをコピーしました。'
    end

    test 'general user can copy submitted announcement' do
      announcement = announcements(:announcement1)
      visit_with_auth announcement_path(announcement), 'kimura'
      within '.announcement' do
        assert_text 'コピー'
      end
    end
  end
end
