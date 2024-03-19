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

  test '.grouping' do
    travel_to Time.zone.local(2017, 4, 3, 10, 0, 0) do
      today_events_group = UpcomingEvent.grouping(:today)[0]

      assert_equal :today, today_events_group[:date_label]
      assert_equal load_events(:today), today_events_group[:events]
      assert_equal Time.zone.today, today_events_group[:event_date]
    end
  end

  private

  def load_events(date)
    (Event.public_send("#{date}_events") + RegularEvent.public_send("#{date}_events")).sort_by { |e| e.start_at.strftime('%H:%M') }
  end
end
