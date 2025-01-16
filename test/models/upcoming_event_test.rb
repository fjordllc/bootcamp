# frozen_string_literal: true

require 'test_helper'

class UpcomingEventTest < ActiveSupport::TestCase
  setup do
    @special_event = events(:event1)
    @regular_event = regular_events(:regular_event1)
  end

  # not testing '.build_group' because this method is used in '.upcoming_events_grpups'.
  test '.upcoming_events_groups' do
    travel_to Time.zone.local(2017, 4, 3, 8, 0, 0) do
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
        regular_events(:regular_event7),
        regular_events(:regular_event33),
        regular_events(:regular_event34)
      ]
      today_upcoming_events = today_events.map { |e| UpcomingEvent.new(e, Time.zone.today) }
      tomorrow_upcoming_events = tomorrow_events.map { |e| UpcomingEvent.new(e, Time.zone.tomorrow) }
      day_after_tomorrow_upcoming_events = day_after_tomorrow_events.map { |e| UpcomingEvent.new(e, Time.zone.tomorrow + 1.day) }

      upcoming_events_groups = UpcomingEvent.upcoming_events_groups

      assert_equal :today, upcoming_events_groups[0].date_key
      assert_equal today_upcoming_events.sort_by(&:scheduled_date_with_start_time),
                   upcoming_events_groups[0].events

      assert_equal :tomorrow, upcoming_events_groups[1].date_key
      assert_equal tomorrow_upcoming_events.sort_by(&:scheduled_date_with_start_time),
                   upcoming_events_groups[1].events

      assert_equal :day_after_tomorrow, upcoming_events_groups[2].date_key
      assert_equal day_after_tomorrow_upcoming_events.sort_by(&:scheduled_date_with_start_time),
                   upcoming_events_groups[2].events
    end
  end

  test 'if original event is Event class, upcominge event always be held on scheduled date' do
    scheduled_date = Date.new(2024, 1, 1) # holiday
    original = @special_event

    upcoming_event = UpcomingEvent.new(original, scheduled_date)
    assert upcoming_event.held_on_scheduled_date?
  end

  test 'if original event is RegularEvent class, whether upcoming event is held on scheduled date depends on rules' do
    scheduled_date = Date.new(2024, 1, 1) # holiday
    original = @regular_event

    original.hold_national_holiday = true
    upcoming_event = UpcomingEvent.new(original, scheduled_date)
    assert upcoming_event.held_on_scheduled_date?

    original.hold_national_holiday = false
    upcoming_event = UpcomingEvent.new(original, scheduled_date)
    assert_not upcoming_event.held_on_scheduled_date?
  end

  test '#scheduled_date_with_start_time' do
    event_scheduled_date = Date.new(2019, 12, 20)

    upcoming_event = UpcomingEvent.new(@special_event, event_scheduled_date)
    assert_equal Time.zone.local(2019, 12, 20, 10), upcoming_event.scheduled_date_with_start_time

    regular_event_scheduled_date = Date.new(2024, 5, 5)

    upcoming_regular_event = UpcomingEvent.new(@regular_event, regular_event_scheduled_date)
    assert_equal Time.zone.local(2024, 5, 5, 15), upcoming_regular_event.scheduled_date_with_start_time
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

  test '.fetch' do
    user = users(:kimura)
    upcoming_events = UpcomingEvent.fetch(user)

    assert Event.where('start_at > ?', Date.current), upcoming_events
  end
end
