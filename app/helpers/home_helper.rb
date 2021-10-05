# frozen_string_literal: true

module HomeHelper
  def today_or_tommorow(event)
    if event.start_at.to_date.today?
      '今日'
    elsif event.start_at.to_date == Date.tomorrow
      '明日'
    end
  end
end
