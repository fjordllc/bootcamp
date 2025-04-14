# frozen_string_literal: true

require 'test_helper'

class PairWorkHelperTest < ActionView::TestCase
  test 'schedule_dates' do
    created_at = Time.zone.local(2025, 1, 1, 0, 0, 0)
    dates = [
      Date.new(2025, 1, 1),
      Date.new(2025, 1, 2),
      Date.new(2025, 1, 3),
      Date.new(2025, 1, 4),
      Date.new(2025, 1, 5),
      Date.new(2025, 1, 6),
      Date.new(2025, 1, 7)
    ]
    assert_equal dates, schedule_dates(created_at)

    date = Date.new(2025, 1, 1)
    assert_equal dates, schedule_dates(date)
  end

  test 'sorted_wdays' do
    wdays_if_wednesday = [3, 4, 5, 6, 0, 1, 2]
    assert_equal wdays_if_wednesday, sorted_wdays(Date.new(2025, 1, 1))
  end
end
