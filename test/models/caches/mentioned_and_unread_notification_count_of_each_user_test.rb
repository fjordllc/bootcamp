# frozen_string_literal: true

require 'test_helper'

class MentionedAndUnreadNotificationCountOfEachUserTest < ActiveSupport::TestCase
  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

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

  test 'cached count of unread mentions is refreshed after deleting cache' do
    receiver = users(:kimura)
    initial_count = Cache.mentioned_and_unread_notification_count(receiver)

    # rubocop:disable Rails/SkipsModelValidations
    Notification.insert_all!(
      [{
        kind: Notification.kinds[:mentioned],
        user_id: receiver.id,
        sender_id: users(:machida).id,
        link: 'path/to/new/link',
        read: false,
        created_at: Time.current,
        updated_at: Time.current
      }]
    )
    # rubocop:enable Rails/SkipsModelValidations

    assert_equal initial_count, Cache.mentioned_and_unread_notification_count(receiver)

    Cache.delete_mentioned_and_unread_notification_count(receiver.id)

    assert_equal initial_count + 1, Cache.mentioned_and_unread_notification_count(receiver)
  end
end
