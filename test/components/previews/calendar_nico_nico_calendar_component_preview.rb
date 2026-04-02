# frozen_string_literal: true

class CalendarNicoNicoCalendarComponentPreview < ViewComponent::Preview
  def default
    user = mock_user
    current_date = Date.current
    current_calendar = build_calendar(current_date)

    render(Calendar::NicoNicoCalendarComponent.new(
      user: user,
      path: '/reports/calendar',
      current_date: current_date,
      current_calendar: current_calendar
    ))
  end

  def with_mixed_emotions
    user = mock_user
    current_date = Date.current
    current_calendar = build_calendar(current_date, emotions: %i[sushi sad normal happy])

    render(Calendar::NicoNicoCalendarComponent.new(
      user: user,
      path: '/reports/calendar',
      current_date: current_date,
      current_calendar: current_calendar
    ))
  end

  private

  def mock_user
    user = OpenStruct.new(
      login_name: 'yamada',
      created_at: 1.year.ago
    )
    user.define_singleton_method(:niconico_calendar) { |cal| cal }
    user
  end

  def build_calendar(date, emotions: [])
    weeks = []
    beginning_of_month = date.beginning_of_month
    beginning_of_week = beginning_of_month.beginning_of_week(:sunday)

    current = beginning_of_week
    while current <= date.end_of_month.end_of_week(:sunday)
      week = []
      7.times do
        emotion = if current.month == date.month && emotions.any?
                    emotions.sample
                  end
        week << { date: current, emotion: emotion }
        current += 1.day
      end
      weeks << week
    end
    weeks
  end
end
