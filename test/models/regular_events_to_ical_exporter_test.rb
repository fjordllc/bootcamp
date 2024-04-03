# frozen_string_literal: true

require 'test_helper'

class RegularEventsToIcalExporterTest < ActiveSupport::TestCase
  test 'check to export special events' do
    travel_to Time.zone.local(2024, 3, 12, 10, 0, 0) do
      user = users(:kimura)

      participated_list = user.regular_event_participations.pluck(:regular_event_id)
    
      holding_events = []
      RegularEvent.where(id: participated_list).where(finished: false).each do |event|#イベントごと
        event.regular_event_repeat_rules.each do |repeat_rule| # ルールごと
          current_date = Date.today
          days_of_the_week_count = 7
    
          while current_date <= Date.today + 1.year do
            if repeat_rule.frequency.zero?
              day_of_the_week_symbol = DateAndTime::Calculations::DAYS_INTO_WEEK.key(repeat_rule.day_of_the_week)
              event_date = current_date.next_occurring(day_of_the_week_symbol).to_date
              event_date = event_date.next_occurring(day_of_the_week_symbol) while !event.hold_national_holiday && HolidayJp.holiday?(event_date)
              current_date =  event_date + 1
              holding_events << { event_id: event.id, event_date: event_date }
            else
              event_date = event.possible_next_event_date(current_date, repeat_rule)
              current_date = current_date.next_month.beginning_of_month
              holding_events << { event_id: event.id, event_date: event_date }
            end  
          end
        end
      end
      holding_events

      calendar = RegularEventsToIcalExporter.export_events(holding_events)

      calendar.publish
      assert_match(/参加反映テスト用定期イベント\(祝日非開催\)/, calendar.to_ical)
      assert_no_match(/未参加反映テスト用定期イベント\(祝日非開催\)/, calendar.to_ical)
    end
  end
end
