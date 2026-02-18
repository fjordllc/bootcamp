# frozen_string_literal: true

module PairWorksHelper
  def schedule_dates(date)
    (0..6).map { |i| date.to_date + i.days }
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

  def schedule_check_disabled?(target_time, pair_work: nil)
    expired = target_time < Time.current
    if pair_work
      expired || pair_work.user_id == current_user.id
    else
      expired
    end
  end

  def learning_time_frame_checked?(target_time, id)
    !schedule_check_disabled?(target_time) && current_user.learning_time_frame_ids.include?(id)
  end

  def schedule_target_time(day_count, hour_count)
    Time.current.beginning_of_day + day_count.days + hour_count.hours
  end

  def schedule_check_box_id(target_time)
    "schedule_ids_#{target_time.strftime('%Y%m%d%H%M')}"
  end
end
