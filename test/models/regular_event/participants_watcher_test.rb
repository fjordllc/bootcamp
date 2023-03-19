# frozen_string_literal: true

require 'test_helper'

class ParticipantsWatcherTest < ActiveSupport::TestCase
  test '.call' do
    regular_event = regular_events(:regular_event3)
    target = User.students_and_trainees.ids - regular_event.watches.pluck(:user_id)
    RegularEvent::ParticipantsWatcher.call(regular_event: regular_event, target: target)

    assert_equal regular_event.watches.count, target.count
  end
end
