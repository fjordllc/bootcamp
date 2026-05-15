# frozen_string_literal: true

class CalendarNicoNicoCalendarComponentPreview < ViewComponent::Preview
  def default
    user = mock_user
    current_date = Date.current
    current_calendar = build_calendar(current_date)

    render(Calendar::NicoNicoCalendarComponent.new(
             user: user,
             path: :niconico_calendar_date_path,
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
             path: :niconico_calendar_date_path,
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
    # 本番のuser_decorator.rbと同じ整形ロジック（先頭ブランク + 7件スライス）
    user.define_singleton_method(:niconico_calendar) do |dates_and_reports|
      first_wday = dates_and_reports.first[:date].wday
      blanks = Array.new(first_wday) { { date: nil, emotion: nil, report: nil } }
      [*blanks, *dates_and_reports].each_slice(7).to_a
    end
    user
  end

  def build_calendar(date, emotions: [])
    # 本番と同じ形式: 日付ごとのフラットな配列（decoratorが週配列に整形する）
    date.beginning_of_month.upto(date.end_of_month).map do |current|
      emotion = emotions.any? ? emotions.sample : nil
      { date: current, emotion: emotion, report: nil }
    end
  end
end
