# frozen_string_literal: true

require 'test_helper'

class RegularEventsToIcalExporterTest < ActiveSupport::TestCase
  test 'check to export regular events' do
    travel_to Time.zone.local(2024, 3, 12, 10, 0, 0) do
      user = users(:kimura)

      calendar = RegularEventsToIcalExporter.export_events(user)

      calendar.publish
      assert_match(/参加反映テスト用定期イベント\(祝日非開催\)/, calendar.to_ical)
      assert_no_match(/未参加反映テスト用定期イベント\(祝日非開催\)/, calendar.to_ical)
    end
  end
end
