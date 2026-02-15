# frozen_string_literal: true

require 'test_helper'

class OrganizerNotifierTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @regular_event = regular_events(:regular_event4)
    @sender = users(:kimura)
  end

  test 'sends a notification when a new organizer is added' do
    new_organizer_users = [users(:hatsuno)]

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      OrganizerNotifier.new.call(nil, nil, nil, nil, { regular_event: @regular_event, new_organizer_users:, sender: @sender })
    end
  end

  test 'does not send a notification when no new organizers are added' do
    new_organizer_users = []

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      OrganizerNotifier.new.call(nil, nil, nil, nil, { regular_event: @regular_event, new_organizer_users:, sender: @sender })
    end
  end

  test 'sends notifications when multiple organizers are added' do
    new_organizer_users = [users(:hatsuno), users(:hajime)]

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      OrganizerNotifier.new.call(nil, nil, nil, nil, { regular_event: @regular_event, new_organizer_users:, sender: @sender })
    end
  end
end
