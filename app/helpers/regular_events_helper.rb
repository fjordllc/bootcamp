# frozen_string_literal: true

module RegularEventsHelper
  def no_holding?(event, date)
    event.no_holding?(date)
  end
end
