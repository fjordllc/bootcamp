# frozen_string_literal: true

module RegularEventsHelper
  def no_holding?(date, event)
    HolidayJp.holiday?(date) && !event.hold_national_holiday
  end
end
