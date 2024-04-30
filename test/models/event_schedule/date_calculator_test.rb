# frozen_string_literal: true

require 'test_helper'

class DateCalculatorTest < ActiveSupport::TestCase
  test '#calc_what_weeks' do
    date1 = Date.parse('2023-12-01')
    assert_equal 1, EventSchedule::DateCalculator.calc_what_weeks_in_month(date1)

    date2 = Date.parse('2023-12-31')
    assert_equal 5, EventSchedule::DateCalculator.calc_what_weeks_in_month(date2)

    date3 = Date.parse('2024-01-01')
    assert_equal 1, EventSchedule::DateCalculator.calc_what_weeks_in_month(date3)

    date4 = Date.parse('2024-01-31')
    assert_equal 5, EventSchedule::DateCalculator.calc_what_weeks_in_month(date4)

    date5 = Date.parse('2026-06-21')
    assert_equal 3, EventSchedule::DateCalculator.calc_what_weeks_in_month(date5)
  end
end
