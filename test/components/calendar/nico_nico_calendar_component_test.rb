# frozen_string_literal: true

require 'test_helper'

class Calendar::NicoNicoCalendarComponentTest < ViewComponent::TestCase
  setup do
    @user = users(:hatsuno).extend(UserDecorator)
    params_date = "#{Date.current.year}-#{Date.current.month}"
    calendar = NicoNicoCalendar.new(@user, params_date)
    @current_date = calendar.current_date
    @current_calendar = calendar.with_reports
    render_inline(Calendar::NicoNicoCalendarComponent.new(
                    user: @user,
                    path: :niconico_calendar_date_path,
                    current_date: @current_date,
                    current_calendar: @current_calendar
                  ))
  end

  # test_prev_month_linkでprev_month?とprev_month_pathメソッド2つのテストを行なってる。nextも同様。
  def test_prev_month_link
    prev_month_str = @current_date.prev_month.strftime('%Y-%m')
    expected_path = "/?niconico_calendar=#{prev_month_str}"
    assert_selector "a[href='#{expected_path}'] .niconico-calendar-nav__previous i.fa-solid.fa-angle-left"
  end

  def test_frame_and_background
    assert_selector '.niconico-calendar__day.is-blank.is-today'
  end

  def test_next_month_link
    render_inline(Calendar::NicoNicoCalendarComponent.new(
                    user: @user,
                    path: :niconico_calendar_date_path,
                    current_date: Date.current.prev_month,
                    current_calendar: @current_calendar
                  ))
    next_month_str = @current_date.strftime('%Y-%m')
    expected_path = "/?niconico_calendar=#{next_month_str}"
    assert_selector "a[href='#{expected_path}'] .niconico-calendar-nav__next i.fa-solid.fa-angle-right"
  end
end
