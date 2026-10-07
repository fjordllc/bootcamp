# frozen_string_literal: true

require 'test_helper'

class WatchTest < ActiveSupport::TestCase
  test 'register creates a watch and touches its user' do
    user = users(:kimura)
    page = pages(:page1)
    user.update!(updated_at: 1.day.ago)

    assert_difference -> { Watch.count }, 1 do
      Watch.register!(user:, watchable: page)
    end

    assert user.watches.exists?(watchable: page)
    assert user.reload.updated_at > 1.minute.ago
  end

  test 'register preserves an existing watch without touching its user' do
    user = users(:kimura)
    page = pages(:page1)
    watch = Watch.register!(user:, watchable: page)
    user.update!(updated_at: 1.day.ago)
    updated_at = user.reload.updated_at

    assert_no_difference -> { Watch.count } do
      assert_equal watch, Watch.register!(user:, watchable: page)
    end
    assert_equal updated_at, user.reload.updated_at
  end

  test 'register raises for invalid watchable' do
    assert_raises ActiveRecord::RecordInvalid do
      Watch.register!(user: users(:kimura), watchable: users(:hatsuno))
    end
  end

  test 'bulk registration skips duplicates and does not touch users' do
    user = users(:kimura)
    other = users(:hatsuno)
    page = pages(:page1)
    existing = Watch.register!(user:, watchable: page)
    user.update!(updated_at: 1.day.ago)
    other.update!(updated_at: 1.day.ago)
    timestamps = [user.reload.updated_at, other.reload.updated_at]

    assert_difference -> { Watch.count }, 1 do
      Watch.register_all(watchable: page, users: [user, other])
    end

    assert_equal existing.id, user.watches.find_by!(watchable: page).id
    assert other.watches.exists?(watchable: page)
    assert_equal timestamps, [user.reload.updated_at, other.reload.updated_at]
  end

  test 'bulk registration accepts no users' do
    assert_no_difference -> { Watch.count } do
      Watch.register_all(watchable: pages(:page1), users: [])
    end
  end
end
