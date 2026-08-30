# frozen_string_literal: true

require 'test_helper'

class HibernationTest < ActiveSupport::TestCase
  setup do
    @user = users(:kimura)
  end

  test 'publishes a cancellation notification for a future reservation' do
    hibernation = Hibernation.new
    pair_work = pair_works(:pair_work2)
    buddy = users(:sotugyou)
    notification_count = 0

    travel_to Time.zone.local(2025, 1, 2, 0, 59, 59) do
      ActiveSupport::Notifications.subscribed(
        ->(*) { notification_count += 1 },
        'pair_work.cancel'
      ) do
        hibernation.send(:unmatch_pair_works, buddy)
      end
    end

    assert_nil pair_work.reload.buddy
    assert_nil pair_work.reserved_at
    assert_equal 1, notification_count
  end

  test 'cancel the pair works by the user' do
    hibernation = Hibernation.create!(
      user: @user,
      reason: '多忙のため',
      scheduled_return_on: Date.current + 3.months
    )
    pair_work = pair_works(:pair_work1)

    assert_difference 'PairWork.count', -2 do
      hibernation.send(:cancel_pair_works, @user)
    end

    assert_not PairWork.exists?(pair_work.id)
  end
end
