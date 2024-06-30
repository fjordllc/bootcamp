# frozen_string_literal: true

module MicroReportsHelper
  def format_date(time)
    if time.to_date == Time.zone.today
      "今日 #{time.strftime('%H:%M')}"
    elsif time.to_date == Date.yesterday
      "昨日 #{time.strftime('%H:%M')}"
    else
      time.strftime('%Y/%m/%d %H:%M')
    end
  end
end
