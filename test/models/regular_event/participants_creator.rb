# frozen_string_literal: true

require 'test_helper'

class ParticipantsCreatorTest < ActiveSupport::TestCase
  test '.call' do
    regular_event = regular_events(:regular_event3)
    target = User.students_and_trainees.ids
    RegularEvent::ParticipantsCreator.call(regular_event: regular_event, target: target)

    assert_equal regular_event.regular_event_participations.count, target.count
  end
end
