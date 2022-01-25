# frozen_string_literal: true

require 'test_helper'

class MentionedAndUnreadNotificationCountOfEachUserTest < ActiveSupport::TestCase
  test 'cached count of unread mentions increases by 1 after creating a mention with new link' do
    receiver = users(:kimura)

    assert_difference -> { Cache.mentioned_and_unread_notification_count(receiver) }, 1 do
      Notification.create!(kind: :mentioned, user: receiver, sender: users(:machida), link: 'path/to/new/link', read: false)
    end
  end

  test 'cached count of unread mentions decreases by 1 after reading an unread mention with unique link' do
    receiver = users(:kimura)
    unread_mention_with_unique_link = Notification.create!(kind: :mentioned, user: receiver, sender: users(:machida), link: 'path/to/unique/link', read: false)

    assert_difference -> { Cache.mentioned_and_unread_notification_count(receiver) }, -1 do
      unread_mention_with_unique_link.update!(read: true)
    end
  end

  test 'cached count of unread mentions decreases by 1 after destroying an unread mention with unique link' do
    receiver = users(:kimura)
    unread_mention_with_unique_link = Notification.create!(kind: :mentioned, user: receiver, sender: users(:machida), link: 'path/to/unique/link', read: false)

    assert_difference -> { Cache.mentioned_and_unread_notification_count(receiver) }, -1 do
      unread_mention_with_unique_link.destroy!
    end
  end
end
