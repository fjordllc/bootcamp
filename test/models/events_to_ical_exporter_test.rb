# frozen_string_literal: true

require 'test_helper'

class EventsToIcalExporterTest < ActiveSupport::TestCase
  test 'check to export special events' do
    travel_to Time.zone.local(2024, 3, 25, 10, 0, 0) do
      user = users(:kimura)

      participated_list = user.participations.pluck(:event_id)
      upcoming_event_list = Event.where('start_at > ?', Time.zone.today).pluck(:id)

      joined_events = Event.where(id: participated_list & upcoming_event_list)
      upcoming_events = Event.where(id: upcoming_event_list).where.not(id: participated_list)
      events_set = {
        joined_events:,
        upcoming_events:
      }
      calendar = EventsToIcalExporter.export_events(events_set)

      calendar.publish
      assert_match(/【参加登録済】未来のイベント\(参加済\)/, calendar.to_ical)
      assert_match(/未来のイベント\(未参加\)/, calendar.to_ical)
      assert_no_match(/過去のイベント/, calendar.to_ical)
    end
  end
end
