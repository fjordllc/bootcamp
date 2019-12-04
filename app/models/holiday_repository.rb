# frozen_string_literal: true

class HolidayRepository
  def self.set_one_month_holidays(beggining_of_this_month)
    holidays = {}
    days_of_this_month = beggining_of_this_month..beggining_of_this_month.end_of_month
    days_of_this_month.each do |one_day|
      if HolidayJp.holiday?(one_day) || one_day.sunday? || one_day.saturday?
        holidays[I18n.l(one_day, format: :ymd_hy)] = 1
      end
    end
    holidays
  end
end
