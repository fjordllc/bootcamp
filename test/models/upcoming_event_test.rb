# frozen_string_literal: true

require 'test_helper'

class UpcomingEventTest < ActiveSupport::TestCase
  test '#fetch' do
    # just counted each events in the yaml file.
    expect_today_events_size = 5
    expect_tomorrow_events_size = 2
    expect_day_after_tomorrow_events_size = 2

    travel_to Time.zone.local(2017, 4, 3, 10, 0, 0) do
      today_events, tomorrow_events, day_after_tomorrow_events = UpcomingEvent.fetch(:today, :tomorrow, :day_after_tomorrow)

      assert_equal '今日', today_events[:day_label]
      assert_equal expect_today_events_size, today_events[:events].count
      assert_equal Time.zone.today, today_events[:holding_date]

      assert_equal '明日', tomorrow_events[:day_label]
      assert_equal expect_tomorrow_events_size, tomorrow_events[:events].count
      assert_equal Time.zone.tomorrow, tomorrow_events[:holding_date]

      assert_equal '明後日', day_after_tomorrow_events[:day_label]
      assert_equal expect_day_after_tomorrow_events_size, day_after_tomorrow_events[:events].count
      assert_equal Time.zone.tomorrow + 1.day, day_after_tomorrow_events[:holding_date]
    end
  end
end
