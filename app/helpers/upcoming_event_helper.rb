# frozen_string_literal: true

module UpcomingEventHelper
  def scheduled_on_pair_works(date_key)
    date = UpcomingEvent::TARGET_TO_DATE[date_key]
    within_day = date.midnight...(date + 1.day).midnight
    PairWork.where(user_id: current_user.id).or(PairWork.where(buddy_id: current_user.id))
            .solved
            .where(reserved_at: within_day)
  end
end
