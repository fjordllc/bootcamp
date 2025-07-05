# frozen_string_literal: true

require 'test_helper'

class ActivityTimesHelperTest < ActionView::TestCase
  include UsersHelper

  test 'format_time_range returns formatted time range' do
    assert_equal '0:00-1:00', format_time_range(0)
    assert_equal '9:00-10:00', format_time_range(9)
    assert_equal '23:00-0:00', format_time_range(23)
  end

  test 'day_names_with_suffix returns days with suffix' do
    expected = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日]
    assert_equal expected, day_names_with_suffix
  end

  test 'clamp_day_index returns valid day index' do
    assert_equal 0, clamp_day_index(0)
    assert_equal 6, clamp_day_index(6)
    assert_equal 6, clamp_day_index(7)
    assert_equal 0, clamp_day_index(-1)
    assert_equal 0, clamp_day_index(nil)
  end

  test 'clamp_hour returns valid hour' do
    assert_equal 0, clamp_hour(0)
    assert_equal 23, clamp_hour(23)
    assert_equal 23, clamp_hour(24)
    assert_equal 0, clamp_hour(-1)
    assert_equal 0, clamp_hour(nil)
  end
end
