# frozen_string_literal: true

require 'test_helper'

module EventSchedule
  class RegularEventScheduleTest < ActiveSupport::TestCase
    setup do
      @every_week_event = regular_events(:regular_event1)
    end

    test 'every week event #tentative_next_event_date' do
      travel_to Time.zone.local(2023, 12, 31, 0, 0, 0) do
        schedule = EventSchedule::RegularEventSchedule.new(@every_week_event)
        assert_equal Time.zone.local(2023, 12, 31, 15, 0, 0), schedule.tentative_next_event_date
      end

      travel_to Time.zone.local(2023, 12, 31, 16, 0, 0) do
        schedule = EventSchedule::RegularEventSchedule.new(@every_week_event)
        assert_equal Time.zone.local(2024, 1, 7, 15, 0, 0), schedule.tentative_next_event_date
      end
    end

    test 'every week event #held_next_event_date' do
      travel_to Time.zone.local(2024, 2, 10, 0, 0, 0) do
        @every_week_event.hold_national_holiday = true
        schedule = EventSchedule::RegularEventSchedule.new(@every_week_event)
        assert_equal Time.zone.local(2024, 2, 11, 15, 0, 0), schedule.held_next_event_date

        @every_week_event.hold_national_holiday = false
        schedule = EventSchedule::RegularEventSchedule.new(@every_week_event)
        # 2024/02/11が祝日のため見送られる
        assert_equal Time.zone.local(2024, 2, 18, 15, 0, 0), schedule.held_next_event_date
      end
    end
  end
end
