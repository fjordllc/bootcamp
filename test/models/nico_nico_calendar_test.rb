# frozen_string_literal: true

require 'test_helper'

class NicoNicoCalendarTest < ActiveSupport::TestCase
  test 'current_calendar_date returns a correct date' do
    april = Date.new(1998, 4)
    calendar = NicoNicoCalendar.new(users(:hatsuno), '1998-04')
    assert_equal calendar.current_date, april
  end

  test 'current_calendar_date does not return a future date, it returns todays date' do
    today = Date.current
    future_date = "#{today.year + 1}-#{today.month}"
    calendar = NicoNicoCalendar.new(users(:hatsuno), future_date)
    assert_equal calendar.current_date, today
  end

  test 'calendar_with_reports returns a calendar with the users daily reports' do
    hajime = users(:hajime)
    calendar = NicoNicoCalendar.new(hajime, '2019-01')
    assert_equal calendar.with_reports.count { |set| set[:report] }, 1
  end
end
