# frozen_string_literal: true

require 'test_helper'

class RegularEventsHelperTest < ActionView::TestCase
  test '#holding return true when event is held' do
    weekdays = Time.zone.parse('2023-9-17')
    holidays = Time.zone.parse('2023-9-18')

    regular_event_held_on_holidays = regular_events(:regular_event4)
    assert holding?(weekdays, regular_event_held_on_holidays)
    assert holding?(holidays, regular_event_held_on_holidays)

    regular_event_not_held_on_holidays = regular_events(:regular_event1)
    assert holding?(weekdays, regular_event_not_held_on_holidays)
  end

  test '#holding return false when event is not held' do
    holidays = Time.zone.parse('2023-9-18')
    regular_event_not_held_on_holidays = regular_events(:regular_event1)

    assert_not holding?(holidays, regular_event_not_held_on_holidays)
  end
end
