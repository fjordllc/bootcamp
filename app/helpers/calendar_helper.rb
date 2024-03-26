# frozen_string_literal: true

module CalendarHelper
  def prev_month?(month, user)
    month.beginning_of_month > user.created_at.to_date.beginning_of_month
  end

  def frame_and_background(date, emotion)
    day_class = emotion ? "is-#{emotion}" : 'is-blank'
    day_class += ' is-today' if date&.today?
    day_class
  end

  def next_month?(month)
    month.beginning_of_month < Time.zone.today.to_date.beginning_of_month
  end
end
