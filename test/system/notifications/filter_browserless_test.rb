# frozen_string_literal: true

require 'browserless_system_test_case'

module Notifications
  class FilterBrowserlessTest < BrowserlessSystemTestCase
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/introduction')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'show listing notification that target is all' do
      Notification.create(message: 'お知らせの通知',
                          kind: 'announced',
                          link: '/announcements/1',
                          user: users(:komagata),
                          sender: users(:machida))
      Notification.create(message: 'コメントの通知',
                          kind: 'came_comment',
                          link: '/reports/1',
                          user: users(:komagata),
                          sender: users(:machida))
      visit_with_auth '/notifications', 'komagata'
      assert_text 'コメントの通知'
      assert_text 'お知らせの通知'
    end

    test 'show listing notification that target is announcements' do
      Notification.create(message: 'お知らせの通知',
                          kind: 'announced',
                          link: '/announcements/1',
                          user: users(:komagata),
                          sender: users(:machida))
      Notification.create(message: 'コメントの通知',
                          kind: 'came_comment',
                          link: '/reports/1',
                          user: users(:komagata),
                          sender: users(:machida))
      visit_with_auth '/notifications?target=announcement', 'komagata'
      assert_text 'お知らせの通知'
      assert_no_text 'コメントの通知'
    end

    test 'show the number of unread mentions on the badge of the mentioned tab' do
      user = users(:kimura)
      expected_number_of_unread_mentions = user.notifications.by_target(:mention).unreads.latest_of_each_link.size

      visit_with_auth '/notifications', user.login_name

      within '.page-tabs__item', text: 'メンション' do
        actual_number_of_unread_mentions = find('.a-notification-count').text.to_i

        assert_equal expected_number_of_unread_mentions, actual_number_of_unread_mentions
      end
    end

    test "don't show the badge on the mentioned tab if no unread mentions" do
      user = users(:kimura)
      user.notifications.by_target(:mention).where(read: false).update_all(read: true) # rubocop:disable Rails/SkipsModelValidations

      visit_with_auth '/notifications', user.login_name

      within '.page-tabs__item', text: 'メンション' do
        assert_no_selector '.a-notification-count'
      end
    end
  end
end
