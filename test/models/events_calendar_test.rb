# frozen_string_literal: true

require 'test_helper'
require 'icalendar'

class EventsCalendarTest < ActiveSupport::TestCase
  test 'check to generate icalendar' do
    travel_to Time.zone.local(2024, 3, 25, 10, 0, 0) do
      user = users(:kimura)

      events_calendar = EventsCalendar.new(user)
      events_calendar.fetch_events

      ical = events_calendar.to_ical

      assert_match(/【参加登録済】未来のイベント\(参加済\)/, ical)
      assert_match(/未来のイベント\(未参加\)/, ical)
      assert_no_match(/過去のイベント/, ical)
      assert_match(/参加反映テスト用定期イベント\(祝日非開催\)/, ical)
      assert_no_match(/未参加反映テスト用定期イベント\(祝日非開催\)/, ical)
    end
  end
end
