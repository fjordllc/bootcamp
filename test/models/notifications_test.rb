# frozen_string_literal: true

require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
    @receiver = users(:mentormentaro)
    @sender = users(:machida)
    @link = 'path/to/link'
    @now = Time.current
  end

  test '.latest_of_each_link' do
    Notification.destroy_all
    old_notification = Notification.create!(user: @receiver, sender: @sender, link: @link, created_at: @now)
    new_notification = Notification.create!(user: @receiver, sender: @sender, link: @link, created_at: @now + 1)

    latest_notifications_of_each_link = Notification.latest_of_each_link.to_a

    assert_not_includes latest_notifications_of_each_link, old_notification
    assert_includes latest_notifications_of_each_link, new_notification
  end

  test '.latest_of_each_link returns only one notification of the latest notifications created at the same time in the same link' do
    Notification.destroy_all
    notification_without_max_id_of_latests = Notification.create!(id: 1, user: @receiver, sender: @sender, link: @link, created_at: @now)
    notification_with_max_id_of_latests = Notification.create!(id: 2, user: @receiver, sender: @sender, link: @link, created_at: @now)

    latest_notifications_of_each_link = Notification.latest_of_each_link.to_a

    assert_not_includes latest_notifications_of_each_link, notification_without_max_id_of_latests
    assert_includes latest_notifications_of_each_link, notification_with_max_id_of_latests
  end
end
