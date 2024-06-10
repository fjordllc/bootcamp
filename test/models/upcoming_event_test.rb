# frozen_string_literal: true

require 'test_helper'

class UpcomingEventTest < ActiveSupport::TestCase
  setup do
    @special_event = events(:event1)
    @regular_event = regular_events(:regular_event1)
  end

  test '.build_upcoming_events_groups' do
    travel_to Time.zone.local(2017, 4, 3, 10, 0, 0) do
      today_events = [
        events(:event27),
        events(:event33),
        regular_events(:regular_event2),
        regular_events(:regular_event26),
        regular_events(:regular_event32)
      ]
      tomorrow_events = [
        events(:event28),
        regular_events(:regular_event27)
      ]
      day_after_tomorrow_events = [
        events(:event32),
        regular_events(:regular_event7)
      ]

      upcoming_events_groups = UpcomingEvent.build_upcoming_events_groups

      assert_equal :today, upcoming_events_groups.first.date_key
      assert_equal Time.zone.today, upcoming_events_groups.first.scheduled_date
      expected_today_events = today_events.map { |e| UpcomingEvent.new(e, Time.zone.today) }
      assert_equal expected_today_events.sort_by(&:scheduled_date_with_start_time), upcoming_events_groups.first.events

      assert_equal :tomorrow, upcoming_events_groups[1].date_key
      assert_equal Time.zone.tomorrow, upcoming_events_groups[1].scheduled_date
      expected_tomorrow_events = tomorrow_events.map { |e| UpcomingEvent.new(e, Time.zone.tomorrow) }
      assert_equal expected_tomorrow_events.sort_by(&:scheduled_date_with_start_time), upcoming_events_groups[1].events

      assert_equal :day_after_tomorrow, upcoming_events_groups[2].date_key
      assert_equal Time.zone.tomorrow + 1.day, upcoming_events_groups[2].scheduled_date
      expected_day_after_tomorrow_events = day_after_tomorrow_events.map { |e| UpcomingEvent.new(e, Time.zone.tomorrow + 1.day) }
      assert_equal expected_day_after_tomorrow_events.sort_by(&:scheduled_date_with_start_time), upcoming_events_groups[2].events
    end
  end

  test '#held_on_scheduled_date? Event always be true' do
    upcoming_special_event = UpcomingEvent.new(@special_event, @holiday)
    assert upcoming_special_event.held_on_scheduled_date?
  end

  test '#held_on_scheduled_date? RegularEvent is dynamic by rules' do
    scheduled_date = Date.new(2024, 1, 1)

    event_held_on_holidays = @regular_event.dup
    event_held_on_holidays.hold_national_holiday = true
    upcoming_regular_event = UpcomingEvent.new(event_held_on_holidays, scheduled_date)
    assert upcoming_regular_event.held_on_scheduled_date?

    event_closed_on_holidays = @regular_event.dup
    event_closed_on_holidays.hold_national_holiday = false
    upcoming_regular_event = UpcomingEvent.new(event_closed_on_holidays, scheduled_date)
    assert_not upcoming_regular_event.held_on_scheduled_date?
  end

  test '#scheduled_date_with_start_time Event' do
    scheduled_date = Date.new(2019, 12, 20)

    upcoming_event = UpcomingEvent.new(@special_event, scheduled_date)
    assert_equal Time.zone.local(2019, 12, 20, 10), upcoming_event.scheduled_date_with_start_time
  end

  test '#scheduled_date_with_start_time RegularEvent' do
    scheduled_date = Date.new(2024, 5, 5) # Sunday

    upcoming_event = UpcomingEvent.new(@regular_event, scheduled_date)
    assert_equal Time.zone.local(2024, 5, 5, 15), upcoming_event.scheduled_date_with_start_time
  end

  test '#for_job_hunting?' do
    scheduled_date = Time.zone.today # 日付はいつでもいいけど、initializeに必要なので定義

    @special_event.update!(job_hunting: true)
    upcoming_special_event = UpcomingEvent.new(@special_event, scheduled_date)
    assert upcoming_special_event.for_job_hunting?

    @special_event.update!(job_hunting: false)
    upcoming_special_event = UpcomingEvent.new(@special_event, scheduled_date)
    assert_not upcoming_special_event.for_job_hunting?
  end
end
