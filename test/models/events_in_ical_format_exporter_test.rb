# frozen_string_literal: true

require 'test_helper'

class EventsInIcalFormatExporterTest < ActiveSupport::TestCase
  test '#export' do
    events = Event.where('start_at > ?', Time.zone.today)
    calendar = EventsInIcalFormatExporter.export_events(events)

    calendar.publish
    assert_match(/明日開催のイベント/, calendar.to_ical)
    assert_no_match(/昨日開催のイベント/, calendar.to_ical)
  end
end
