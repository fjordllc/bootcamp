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

    assert_equal 1, notification_count
  end
end
