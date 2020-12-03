# frozen_string_literal: true

class Holiday
  def self.one_month_holidays(beggining_of_this_month)
    holidays = {}
    days_of_this_month = beggining_of_this_month..beggining_of_this_month.end_of_month
    days_of_this_month.each do |one_day|
      holidays[I18n.l(one_day, format: :ymd_hy)] = 1 if HolidayJp.holiday?(one_day) || one_day.sunday? || one_day.saturday?
    end
    holidays
  end
end
