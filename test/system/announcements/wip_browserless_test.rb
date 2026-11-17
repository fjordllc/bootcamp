# frozen_string_literal: true

require 'browserless_system_test_case'

module Announcements
  class WipBrowserlessTest < BrowserlessSystemTestCase
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'show WIP message' do
      user = users(:komagata)
      Announcement.create(title: 'test', description: 'test', user:, wip: true)
      visit_with_auth '/announcements', 'kimura'
      assert_selector '.a-list-item-badge'
      assert_text 'お知らせ作成中'
    end

    test 'general user can copy wip announcement' do
      announcement = announcements(:announcement_wip)
      visit_with_auth announcement_path(announcement), 'kimura'
      within '.announcement' do
        assert_text '複製'
      end
    end
  end
end
