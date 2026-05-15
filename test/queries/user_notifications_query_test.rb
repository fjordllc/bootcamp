# frozen_string_literal: true

require 'test_helper'

class UserNotificationsQueryTest < ActiveSupport::TestCase
  test 'should return notifications for the given user' do
    user = users(:komagata)
    other_user = users(:machida)

    Notification.create!(user:, sender: other_user, kind: :came_comment, link: '/comments/1')
    Notification.create!(user: other_user, sender: user, kind: :came_comment, link: '/comments/2')

    result = UserNotificationsQuery.new(user:, target: nil, status: nil).call

    assert_includes result.map(&:user), user
    assert_not_includes result.map(&:user), other_user
  end

  test 'should return unread notifications when status is unread' do
    user = users(:komagata)
    sender = users(:machida)

    read_notification = Notification.create!(user:, sender:, kind: :checked, read: true, link: '/checks/1')
    unread_notification = Notification.create!(user:, sender:, kind: :checked, read: false, link: '/checks/2')

    result = UserNotificationsQuery.new(user:, target: 'check', status: 'unread').call

    assert_includes result, unread_notification
    assert_not_includes result, read_notification
  end

  test 'should return notifications for given target' do
    user = users(:komagata)
    sender = users(:machida)

    comment_notification = Notification.create!(user:, sender:, kind: :came_comment, link: '/comments/1')
    check_notification = Notification.create!(user:, sender:, kind: :checked, link: '/checks/1')

    result = UserNotificationsQuery.new(user:, target: 'check', status: 'unread').call

    assert_includes result, check_notification
    assert_not_includes result, comment_notification
  end
end
