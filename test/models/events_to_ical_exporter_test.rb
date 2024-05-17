# frozen_string_literal: true

require 'test_helper'

class EventsToIcalExporterTest < ActiveSupport::TestCase
  test 'check to export special events' do
    travel_to Time.zone.local(2024, 3, 25, 10, 0, 0) do
      user = users(:kimura)

      calendar = EventsToIcalExporter.new
      subscription_calendar = calendar.export_events(user)

      subscription_calendar.publish
      assert_match(/【参加登録済】未来のイベント\(参加済\)/, subscription_calendar.to_ical)
      assert_match(/未来のイベント\(未参加\)/, subscription_calendar.to_ical)
      assert_no_match(/過去のイベント/, subscription_calendar.to_ical)
    end
  end
end
