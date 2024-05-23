# frozen_string_literal: true

require 'test_helper'

class UpcomingEventTest < ActiveSupport::TestCase
  setup do
    @holiday = Date.new(2024, 1, 1)
    @special_event = events(:event1)
    @regular_event = regular_events(:regular_event1)
  end

  test '#held?(date) Event always be true' do
    upcoming_special_event = UpcomingEvent.new(@special_event, @holiday)

    assert upcoming_special_event.held?(@holiday)
  end

  test '#held?(date) RegularEvent is dynamic by rules' do
    held_holiday_event = @regular_event.dup
    held_holiday_event.hold_national_holiday = true

    upcoming_regular_event = UpcomingEvent.new(held_holiday_event, @holiday)

    assert upcoming_regular_event.held?(@holiday)

    not_held_holiday_event = @regular_event.dup
    not_held_holiday_event.hold_national_holiday = false

    upcoming_regular_event = UpcomingEvent.new(not_held_holiday_event, @holiday)

    assert_not upcoming_regular_event.held?(@holiday)
  end

  test '#date_with_start_time(date) Event' do
    scheduled_date = Date.new(2019, 12, 20)

    upcoming_event = UpcomingEvent.new(@special_event, scheduled_date)

    assert_equal Time.zone.local(2019, 12, 20, 10), upcoming_event.date_with_start_time(scheduled_date)
  end

  test '#date_with_start_time(date) RegularEvent' do
    scheduled_date = Date.new(2024, 5, 5) # Sunday

    upcoming_event = UpcomingEvent.new(@regular_event, scheduled_date)

    assert_equal Time.zone.local(2024, 5, 5, 15), upcoming_event.date_with_start_time(scheduled_date)
  end

  test '#for_job_hunting?' do
    @special_event.update!(job_hunting: true)
    scheduled_date = Time.zone.today

    upcoming_special_event = UpcomingEvent.new(@special_event, scheduled_date)

    assert upcoming_special_event.for_job_hunting?

    @special_event.update!(job_hunting: false)
    upcoming_special_event = UpcomingEvent.new(@special_event, scheduled_date)

    assert_not upcoming_special_event.for_job_hunting?
  end
end
