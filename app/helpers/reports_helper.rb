# frozen_string_literal: true

module ReportsHelper
  def recent_reports
    @recent_reports ||= Report.with_avatar
                              .preload(:checks)
                              .order(updated_at: :desc, id: :desc)
                              .limit(15)
  end

  def practice_options(categories)
    categories.flat_map do |category|
      category.practices.map do |practice|
        ["[#{category.name}] #{practice.title}", practice.id]
      end
    end
  end

  def convert_to_hour_minute(time)
    hour = (time / 60).to_i
    minute = (time % 60).round

    if minute == 0
      "#{hour}時間"
    else
      "#{hour}時間#{minute}分"
    end
  end

  def unchecked_report_count
    @_unchecked_report_count ||= Report.unchecked.not_wip.count
  end
end
