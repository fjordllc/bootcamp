

# frozen_string_literal: true

require 'test_helper'

class ParticipantsWatcherTest < ActiveSupport::TestCase
  test '.call' do
    regular_event = regular_events(:regular_event3)
    target = User.students_and_trainees.ids - regular_event.watches.pluck(:user_id)
    RegularEvent::ParticipantsWatcher.call(regular_event: regular_event, target: target)

    assert_equal regular_event.watches.count, target.count
  end

  test '.call with date_time' do
    regular_event = regular_events(:regular_event3)
    target = User.students_and_trainees.ids - regular_event.watches.pluck(:user_id)
    date_time = Time.current.end_of_day.floor
    RegularEvent::ParticipantsWatcher.call(regular_event: regular_event, target: target, date_time: date_time)

    assert_equal regular_event.watches.count, target.count
    assert_equal regular_event.watches.first.created_at, date_time
  end
end
