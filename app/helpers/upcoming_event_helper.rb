# frozen_string_literal: true

module UpcomingEventHelper
  def scheduled_on_pair_works(date_key)
    date = UpcomingEvent::TARGET_TO_DATE[date_key]
    pair_works = PairWork.where(user_id: current_user.id).or(PairWork.where(buddy_id: current_user.id))
    pair_works.solved.filter { |pair_work| (date.midnight...(date + 1.day).midnight).cover?(pair_work.reserved_at) }
  end
end
