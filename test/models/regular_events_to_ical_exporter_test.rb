# frozen_string_literal: true

require 'test_helper'

class RegularEventsToIcalExporterTest < ActiveSupport::TestCase
  test 'check to export special events' do
    travel_to Time.zone.local(2024, 3, 12, 10, 0, 0) do
      user = users(:kimura)

      participated_list = user.regular_event_participations.pluck(:regular_event_id)

      holding_events = []
      RegularEvent.where(id: participated_list).where(finished: false).find_each do |event|
        event.regular_event_repeat_rules.each do |repeat_rule|
          current_date = Time.zone.today

          while current_date <= Time.zone.today + 1.year
            if repeat_rule.frequency.zero?
              day_of_the_week_symbol = DateAndTime::Calculations::DAYS_INTO_WEEK.key(repeat_rule.day_of_the_week)
              event_date = current_date.next_occurring(day_of_the_week_symbol).to_date
              event_date = event_date.next_occurring(day_of_the_week_symbol) while !event.hold_national_holiday && HolidayJp.holiday?(event_date)
              current_date = event_date + 1
            else
              event_date = event.possible_next_event_date(current_date, repeat_rule)
              current_date = current_date.next_month.beginning_of_month
            end
            holding_events << { event_id: event.id, event_date: }
          end
        end
      end

      calendar = RegularEventsToIcalExporter.export_events(holding_events)

      calendar.publish
      assert_match(/参加反映テスト用定期イベント\(祝日非開催\)/, calendar.to_ical)
      assert_no_match(/未参加反映テスト用定期イベント\(祝日非開催\)/, calendar.to_ical)
    end
  end
end