# frozen_string_literal: true

require 'test_helper'

class OrganizerCreateNotifierTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @regular_event = regular_events(:regular_event4)
    @before_organizer_ids = @regular_event.organizer_ids
    @sender = users(:kimura)
  end

  test 'sends a notification when new organizers exist' do
    user = users(:hatsuno)
    Organizer.create!(user_id: user.id, regular_event_id: @regular_event.id)

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      OrganizerCreateNotifier.new.call(nil, nil, nil, nil, { regular_event: @regular_event, before_organizer_ids: @before_organizer_ids, sender: @sender })
    end
  end

  test 'does not send a notification when no new organizers exist' do
    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 0 do
      OrganizerCreateNotifier.new.call(nil, nil, nil, nil, { regular_event: @regular_event, before_organizer_ids: @before_organizer_ids, sender: @sender })
    end
  end
end
