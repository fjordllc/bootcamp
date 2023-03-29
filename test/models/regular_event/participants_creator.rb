# frozen_string_literal: true

require 'test_helper'

class ParticipantsCreatorTest < ActiveSupport::TestCase
  test '.call' do
    regular_event = regular_events(:regular_event3)
    target = User.students_and_trainees.ids
    RegularEvent::ParticipantsCreator.call(regular_event: regular_event, target: target)

    assert_equal regular_event.regular_event_participations.count, target.count
  end

  test '.call with date_time' do
    regular_event = regular_events(:regular_event3)
    target = User.students_and_trainees.ids
    date_time = Time.current.end_of_day.floor
    RegularEvent::ParticipantsCreator.call(regular_event: regular_event, target: target, date_time: date_time)

    assert_equal regular_event.regular_event_participations.count, target.count
    assert_equal regular_event.regular_event_participations.first.created_at, date_time
  end
end
