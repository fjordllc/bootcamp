# frozen_string_literal: true

require 'application_system_test_case'

module Notifications
  class CountTest < ApplicationSystemTestCase
    include ActiveJob::TestHelper

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

    test 'show notification count' do
      user = users(:kananashi)
      sender = users(:machida)
      Notification.create(message: 'machidaさんからメンションが届きました',
                          created_at: '2040-01-18 06:06:42',
                          kind: 'mentioned',
                          link: '/reports/20400118',
                          user:,
                          sender:)

      visit_with_auth '/notifications', 'kananashi'
      assert_selector '.header-notification-count', text: '1'

      now = Time.current
      notifications = Array.new(20) do |n|
        {
          message: "machidaさんからメンションが届きました#{n}",
          kind: 'mentioned',
          link: "/reports/#{n}",
          user_id: user.id,
          sender_id: sender.id,
          created_at: now,
          updated_at: now
        }
      end
      Notification.insert_all(notifications) # rubocop:disable Rails/SkipsModelValidations
      visit_with_auth '/notifications', 'kananashi'
      assert_selector '.header-notification-count', text: '21'
    end

    test 'show listing unread notification' do
      visit_with_auth '/notifications?status=unread', 'hatsuno'
      assert_equal '通知 | FBC', title
    end

    test 'non-mentor can not see a button to open all unread notifications' do
      Notification.create(message: 'machidaさんがコメントしました',
                          kind: 'came_comment',
                          link: '/reports/20400118',
                          user: users(:hatsuno),
                          sender: users(:machida))
      visit_with_auth '/notifications?status=unread', 'hatsuno'
      assert_no_button '未読の通知を一括で開く'
    end

    test 'mentor can see a button to open to open all unread notifications' do
      Notification.create(message: 'machidaさんがコメントしました',
                          kind: 'came_comment',
                          link: '/reports/20400118',
                          user: users(:komagata),
                          sender: users(:machida))
      visit_with_auth '/notifications?status=unread', 'komagata'
      assert_button '未読の通知を一括で開く'
    end
  end
end
