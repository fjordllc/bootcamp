# frozen_string_literal: true

require 'test_helper'

class EventScheduleTest < ActiveSupport::TestCase
  setup do
    @special_event = events(:event1)
    @regular_event = regular_events(:regular_event1)
  end

  test '.load' do
    assert_instance_of EventSchedule::SpecialEventSchedule, EventSchedule.load(@special_event)
    assert_instance_of EventSchedule::RegularEventSchedule, EventSchedule.load(@regular_event)
  end
end
