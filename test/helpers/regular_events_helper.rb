# frozen_string_literal: true

require 'test_helper'

class RegularEventsHelperTest < ActionView::TestCase
  test '#no_holding return true when event is not held' do
    holidays = Time.zone.parse('2023-9-18')
    weekdays = Time.zone.parse('2023-9-19')

    regular_event_not_held_on_holidays = regular_events(:regular_event1)
    assert no_holding?(regular_event_not_held_on_holidays, holidays)
    assert_not no_holding?(regular_event_not_held_on_holidays, weekdays)

    regular_event_held_on_holidays = regular_events(:regular_event4)
    assert_not no_holding?(regular_event_held_on_holidays, weekdays)
    assert_not no_holding?(regular_event_held_on_holidays, holidays)
  end
end
