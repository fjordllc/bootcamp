# frozen_string_literal: true

require 'test_helper'

class CalendarHelperTest < ActionView::TestCase
  include CalendarHelper

  def setup
    @user = users(:kimura)
    @user.created_at = Time.zone.parse('1998-01-19')
    @date = Date.current
    @emotion = 'happy'
  end
  test 'prev_month? returns true if month is not oldest month' do
    assert prev_month?(@user.created_at + 2.months, @user)
  end

  test 'prev_month? returns false if month is not oldest month' do
    assert_not prev_month?(@user.created_at - 2.months, @user)
  end

  test 'frame_and_background returns is-today if date is today' do
    assert_includes frame_and_background(@date, nil), 'is-today'
  end

  test 'frame_and_background returns is-happy if emotion is happy' do
    assert_includes frame_and_background(@date, @emotion), 'is-happy'
  end

  test 'next_month? returns true if month is not latest month' do
    assert next_month?(@date - 2.months)
  end

  test 'next_month? returns false if month is not latest month' do
    assert_not next_month?(@date)
  end
end
