# frozen_string_literal: true

module RegularEventsHelper
  def holding?(date, event)
    return true unless HolidayJp.holiday?(date)

    event.hold_national_holiday
  end
end
