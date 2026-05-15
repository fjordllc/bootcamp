# frozen_string_literal: true

require 'test_helper'

class TimeHelperTest < ActionView::TestCase
  test 'minute_to_span' do
    assert_equal '2時間40分', minute_to_span(160)
    assert_equal '3時間', minute_to_span(180)
  end
end
