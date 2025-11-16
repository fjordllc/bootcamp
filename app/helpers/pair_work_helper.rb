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

  def disabled?(target_date, pair_work: nil)
    if pair_work
      target_date < Time.current || pair_work.user_id == current_user.id
    else
      target_date < Time.current
    end
  end

  def learning_time_frame_checked?(target_date, id)
    !disabled?(target_date) && current_user.learning_time_frame_ids.include?(id)
  end

  def schedule_time(day_count, hour_count)
    Time.current.beginning_of_day + day_count.days + hour_count.hour
  end

  def schedule_check_box_id(target_time)
    "schedule_ids_#{target_time.strftime('%Y%m%d%H%M')}"
  end
end
