# frozen_string_literal: true

require 'test_helper'

class UpcomingEventTest < ActiveSupport::TestCase
  test '.today_events' do
    assert_equal load_events(:today), UpcomingEvent.today_events
  end

  test '.tomorrow_events' do
    assert_equal load_events(:tomorrow), UpcomingEvent.tomorrow_events
  end

  test '.day_after_tomorrow_events' do
    assert_equal load_events(:day_after_tomorrow), UpcomingEvent.day_after_tomorrow_events
  end

  test '.fetch' do
    travel_to Time.zone.local(2017, 4, 3, 10, 0, 0) do
      today_events, tomorrow_events, day_after_tomorrow_events = UpcomingEvent.fetch(:today, :tomorrow, :day_after_tomorrow)

      assert_equal :today, today_events[:date_label]
      assert_equal load_events(:today), today_events[:events]
      assert_equal Time.zone.today, today_events[:event_date]

      assert_equal :tomorrow, tomorrow_events[:date_label]
      assert_equal load_events(:tomorrow), tomorrow_events[:events]
      assert_equal Time.zone.tomorrow, tomorrow_events[:event_date]

      assert_equal :day_after_tomorrow, day_after_tomorrow_events[:date_label]
      assert_equal load_events(:day_after_tomorrow), day_after_tomorrow_events[:events]
      assert_equal Time.zone.tomorrow + 1.day, day_after_tomorrow_events[:event_date]
    end
  end

  private

  def load_events(date)
    (Event.public_send("#{date}_events") + RegularEvent.public_send("#{date}_events")).sort_by { |e| e.start_at.strftime('%H:%M') }
  end
end
