# frozen_string_literal: true

require 'test_helper'

class EventsCalendarTest < ActiveSupport::TestCase
  test 'check to generate icalendar' do
    travel_to Time.zone.local(2024, 3, 25, 10, 0, 0) do
      user = users(:kimura)

      calendar = Calendar.new
      subscription_calendar = calendar.combine_special_regular_calendar(user).publish

      subscription_calendar.publish
      assert_match(/【参加登録済】未来のイベント\(参加済\)/, subscription_calendar.to_ical)
      assert_match(/未来のイベント\(未参加\)/, subscription_calendar.to_ical)
      assert_no_match(/過去のイベント/, subscription_calendar.to_ical)
      assert_match(/参加反映テスト用定期イベント\(祝日非開催\)/, subscription_calendar.to_ical)
      assert_no_match(/未参加反映テスト用定期イベント\(祝日非開催\)/, subscription_calendar.to_ical)
    end
  end
end
