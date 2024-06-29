# frozen_string_literal: true

require 'test_helper'

class Calendar::NicoNicoCalendarComponentTest < ViewComponent::TestCase
  setup do
    @user = users(:hatsuno).extend(UserDecorator)
    @current_date = "#{Date.current.year}-#{Date.current.month}"
    calendar = NicoNicoCalendar.new(@user, @current_date)
    @current_date = calendar.current_date
    @current_calendar = calendar.with_reports
    render_inline(Calendar::NicoNicoCalendarComponent.new(
                    user: @user,
                    path: :niconico_calendar_date_path,
                    current_date: @current_date,
                    current_calendar: @current_calendar
                  ))
  end

  def test_prev_month?
    assert_selector '.niconico-calendar-nav__previous'
  end

  def test_frame_and_background
    assert_selector '.niconico-calendar__day.is-blank.is-today'
  end

  def test_next_month?
    render_inline(Calendar::NicoNicoCalendarComponent.new(
                    user: @user,
                    path: :niconico_calendar_date_path,
                    current_date: Date.current.prev_month,
                    current_calendar: @current_calendar
                  ))
    assert_selector '.niconico-calendar-nav__next'
  end
end
