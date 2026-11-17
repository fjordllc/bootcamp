# frozen_string_literal: true

require 'application_system_test_case'

module Notifications
  class FilterTest < ApplicationSystemTestCase
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

    test 'show listing unread notification that target is announcements' do
      Notification.create(message: '未読のお知らせの通知',
                          kind: 'announced',
                          link: '/announcements/1',
                          user: users(:komagata),
                          sender: users(:machida))
      Notification.create(message: '既読のお知らせの通知',
                          kind: 'announced',
                          link: '/announcements/2',
                          user: users(:komagata),
                          sender: users(:machida),
                          read: true)
      visit_with_auth '/notifications?status=unread&target=announcement', 'komagata'
      assert_text '未読のお知らせの通知'
      assert_no_text '既読のお知らせの通知'
    end

    test 'click on the category marks button' do
      Notification.create(message: 'お知らせのテスト通知',
                          kind: 'announced',
                          link: '/announcements/1',
                          user: users(:komagata),
                          sender: users(:machida))
      Notification.create(message: 'コメントのテスト通知',
                          kind: 'came_comment',
                          link: '/reports/1',
                          user: users(:komagata),
                          sender: users(:machida))
      visit_with_auth '/notifications?status=unread&target=announcement', 'komagata'
      click_link 'お知らせを既読にする'

      visit_with_auth '/notifications?status=unread&target=announcement', 'komagata'
      assert_no_text 'お知らせのテスト通知'

      visit_with_auth '/notifications?status=unread&target=comment', 'komagata'
      assert_text 'コメントのテスト通知'

      visit_with_auth '/notifications?status=unread', 'komagata'
      assert_text 'コメントのテスト通知'
    end

    test 'Unread and All buttons should always be displayed' do
      user = users(:kimura)
      visit_with_auth '/notifications', user.login_name
      assert_selector '.pill-nav__item-link.is-active'

      visit '/notifications?status=unread&target=check'
      assert_selector '.pill-nav__item-link.is-active'
    end
  end
end
