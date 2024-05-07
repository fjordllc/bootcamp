# frozen_string_literal: true

require 'test_helper'

class SpecialEventScheduleTest < ActiveSupport::TestCase
  setup do
    @special_event = events(:event1)
    @special_event.update!(
      start_at: Time.zone.local(2024, 1, 1, 9, 0),
      end_at: Time.zone.local(2024, 1, 1, 11, 0)
    )
    @schedule = EventSchedule::Event.new(@special_event)
  end

  test '.tentative_next_event_date' do
    travel_to Time.zone.local(2023, 12, 31, 0, 0, 0) do
      assert_equal Time.zone.local(2024, 1, 1, 9, 0, 0), @schedule.tentative_next_event_date
    end
  end
end
