# frozen_string_literal: true

require 'test_helper'

class HibernationNotificationsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  # 受講生、研修生、アドバイザー
  %w[kimura kensyu senpai].each do |login_name|
    test "admins and mentors are notified when #{login_name} hibernates" do
      post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }

      perform_enqueued_jobs do
        post hibernation_path, params: { hibernation: { scheduled_return_on: Date.current.next_month, reason: 'テストのため' } }
      end

      assert_redirected_to hibernation_path
      assert users(login_name).reload.hibernated?
      %i[komagata mentormentaro].each do |receiver|
        assert_equal ["#{login_name}さんが休会しました。"],
                     Notification.where(user: users(receiver), kind: :hibernated, sender: users(login_name)).map(&:message)
      end
      assert_empty Notification.where(user: users(:hatsuno), kind: :hibernated, sender: users(login_name))
    end
  end
end
