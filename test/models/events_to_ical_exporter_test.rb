# frozen_string_literal: true

require 'test_helper'

class EventsToIcalExporterTest < ActiveSupport::TestCase
  test 'check to export only feature events' do
    travel_to Time.zone.local(2023, 5, 19, 10, 0, 0) do
      events = Event.where('start_at > ?', Time.zone.today)
      calendar = EventsToIcalExporter.export_events(events)

      calendar.publish
      assert_match(/明日開催のイベント/, calendar.to_ical)
      assert_no_match(/昨日開催のイベント/, calendar.to_ical)
    end
  end
end
