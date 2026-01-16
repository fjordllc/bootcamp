# frozen_string_literal: true

require 'test_helper'

class OrganizerCreateNotifierTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @sender = users(:kimura)
  end

  test 'sends a notification when a new organizer is added' do
    regular_event = regular_events(:regular_event4)
    before_organizer_ids = regular_event.organizer_ids
    user = users(:hatsuno)

    Organizer.create!(user_id: user.id, regular_event_id: regular_event.id)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      OrganizerCreateNotifier.new.call(nil, nil, nil, nil, { regular_event:, before_organizer_ids:, sender: @sender })
    end
  end

  test 'does not send a notification when no new organizers are added' do
    regular_event = regular_events(:regular_event4)
    before_organizer_ids = regular_event.organizer_ids

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      OrganizerCreateNotifier.new.call(nil, nil, nil, nil, { regular_event:, before_organizer_ids:, sender: @sender })
    end
  end

  test 'sends notifications when multiple organizers are added' do
    regular_event = regular_events(:regular_event5)
    before_organizer_ids = regular_event.organizer_ids
    user1 = users(:hatsuno)
    user2 = users(:hajime)
    Organizer.create!(user_id: user1.id, regular_event_id: regular_event.id)
    Organizer.create!(user_id: user2.id, regular_event_id: regular_event.id)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      OrganizerCreateNotifier.new.call(nil, nil, nil, nil, { regular_event:, before_organizer_ids:, sender: @sender })
    end
  end

  test 'sends a notification when an organizer is replaced' do
    regular_event = regular_events(:regular_event5)
    before_organizer_ids = regular_event.organizer_ids
    user = users(:hatsuno)
    Organizer.create!(user_id: user.id, regular_event_id: regular_event.id)
    Organizer.find_by!(user_id: @sender.id, regular_event_id: regular_event.id).destroy!

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      OrganizerCreateNotifier.new.call(nil, nil, nil, nil, { regular_event:, before_organizer_ids:, sender: @sender })
    end
  end
end
