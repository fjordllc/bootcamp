# frozen_string_literal: true

require 'test_helper'

class UpcomingEventTest < ActiveSupport::TestCase
  setup do
    @holiday = Date.new(2024, 1, 1)
    @special_event = events(:event1)
    @regular_event = regular_events(:regular_event1)
  end

  test '#held?(date) Event always be true' do
    upcoming = UpcomingEvent.new(@special_event)
    assert upcoming.held?(@holiday)
  end

  test '#held?(date) RegularEvent is dynamic by rules' do
    held_holiday = @regular_event.dup
    held_holiday.hold_national_holiday = true
    upcoming = UpcomingEvent.new(held_holiday)
    assert upcoming.held?(@holiday)

    not_held_holiday = @regular_event.dup
    not_held_holiday.hold_national_holiday = false
    upcoming = UpcomingEvent.new(not_held_holiday)
    assert_not upcoming.held?(@holiday)
  end

  test '#date_with_start_time(date) Event' do
    date = Date.new(2019, 12, 20)
    upcoming = UpcomingEvent.new(@special_event)
    assert_equal Time.zone.local(2019, 12, 20, 10), upcoming.date_with_start_time(date)
  end

  test '#date_with_start_time(date) RegularEvent' do
    date = Date.new(2024, 5, 5) # Sunday
    upcoming = UpcomingEvent.new(@regular_event)
    assert_equal Time.zone.local(2024, 5, 5, 15), upcoming.date_with_start_time(date)
  end

  test '#for_job_hunting?' do
    @special_event.update!(job_hunting: true)
    upcoming_special = UpcomingEvent.new(@special_event)
    assert upcoming_special.for_job_hunting?

    @special_event.update!(job_hunting: false)
    upcoming_special = UpcomingEvent.new(@special_event)
    assert_not upcoming_special.for_job_hunting?
  end
end
