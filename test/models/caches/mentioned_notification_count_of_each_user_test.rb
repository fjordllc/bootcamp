# frozen_string_literal: true

require 'test_helper'

class MentionedNotificationCountOfEachUserTest < ActiveSupport::TestCase
  test 'cached count of mentioned notifications increases by 1 after creating a mentioned notification with new link' do
    receiver = users(:kimura)

    assert_difference -> { Cache.mentioned_notification_count(receiver) }, 1 do
      Notification.create!(kind: :mentioned, user: receiver, sender: users(:machida), link: 'path/to/new/link')
    end
  end

  test 'cached count of mentioned notifications decreases by 1 after destroying an mentioned notification with unique link' do
    receiver = users(:kimura)
    mentioned_notification_with_unique_link = Notification.create!(kind: :mentioned, user: receiver, sender: users(:machida), link: 'path/to/unique/link')

    assert_difference -> { Cache.mentioned_notification_count(receiver) }, -1 do
      mentioned_notification_with_unique_link.destroy!
    end
  end
end
