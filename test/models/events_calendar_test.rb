# frozen_string_literal: true

require 'test_helper'
require 'icalendar'

class EventsCalendarTest < ActiveSupport::TestCase
  test 'check to generate icalendar' do
    travel_to Time.zone.local(2024, 3, 25, 10, 0, 0) do
      user = users(:kimura)

      events_calendar = EventsCalendar.new(user)
      @events = events_calendar.events

      cal = Icalendar::Calendar.new

      @events.each do |event|
        cal.event do |e|
          e.dtstart     = Icalendar::Values::DateTime.new(event.start_at)
          e.dtend       = Icalendar::Values::DateTime.new(event.end_at)
          e.summary     = event.title
          e.description = event.description
          e.location    = event.respond_to?(:location) && event.location.present? ? event.location : nil
          e.uid         = event.id.to_s
        end
      end

      ical = cal.to_ical

      assert_match(/【参加登録済】未来のイベント\(参加済\)/, ical)
      assert_match(/未来のイベント\(未参加\)/, ical)
      assert_no_match(/過去のイベント/, ical)
      assert_match(/参加反映テスト用定期イベント\(祝日非開催\)/, ical)
      assert_no_match(/未参加反映テスト用定期イベント\(祝日非開催\)/, ical)
    end
  end
end
