# frozen_string_literal: true

require 'test_helper'

class TimeRangeHelperTest < ActionView::TestCase
  test 'formats weekday and time correctly' do
    time = Time.zone.local(2025, 8, 29, 14, 30)
    assert_equal '(金) 14:00 〜 15:00', time_range(time)
  end

  test 'formats exactly on the hour' do
    time = Time.zone.local(2025, 8, 29, 10, 0)
    assert_equal '(金) 10:00 〜 11:00', time_range(time)
  end

  test 'formats time crossing midnight' do
    time = Time.zone.local(2025, 8, 31, 23, 59)
    assert_equal '(日) 23:00 〜 00:00', time_range(time)
  end
end
