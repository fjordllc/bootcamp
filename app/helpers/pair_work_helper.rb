# frozen_string_literal: true

module PairWorkHelper
  def schedule_dates(date)
    (0..6).map { |i| date.to_date + i.day }
  end

  def sorted_wdays(date)
    max_wday = 6
    sorted_wdays = [date.wday]
    max_wday.times do
      next sorted_wdays << 0 if sorted_wdays.last == max_wday

      sorted_wdays << sorted_wdays.last + 1
    end
    sorted_wdays
  end

  def disabled(value)
    value < Time.current
  end

  def checked(value, id)
    !disabled(value) && current_user.learning_time_frame_ids.include?(id)
  end
end
