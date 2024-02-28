# frozen_string_literal: true

require 'test_helper'

class CalendarMethodsTest < ActiveSupport::TestCase
  class ExampleController < ApplicationController
    include CalendarMethods
  end

  setup do
    @controller = ExampleController.new
  end

  test 'current_calendar_date returns a correct date' do
    april = Date.new(1998, 4)
    assert_equal @controller.current_calendar_date('1998-04'), april
  end

  test 'current_calendar_date does not return a future date, it returns todays date' do
    today = Date.current
    future_date = "#{today.year + 1}-#{today.month}"
    assert_equal @controller.current_calendar_date(future_date), today
  end

  test 'calendar_with_reports returns a calendar with the users daily reports' do
    hajime = users(:hajime)
    date = @controller.current_calendar_date('2019-01')
    calendar = @controller.calendar_with_reports(hajime, date)
    assert_equal calendar.select { |set| set[:report] }.count, 1
  end
end
