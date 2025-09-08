# frozen_string_literal: true

module TimeRangeHelper
  def time_range(time)
    start_hour = time.change(min: 0, sec: 0)
    end_hour = start_hour + 1.hour

    "(#{I18n.t('date.abbr_day_names')[time.wday]}) #{start_hour.strftime('%H:%M')} 〜 #{end_hour.strftime('%H:%M')}"
  end
end
