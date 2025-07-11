# frozen_string_literal: true

class DashboardPairWorkPresenter
  def initialize(user)
    @user = user
  end

  def upcoming_pair_works
    today = Date.current
    within_day = today.midnight...(today + 3).midnight
    PairWork.where(user_id: @user.id).or(PairWork.where(buddy_id: @user.id))
            .solved
            .where(reserved_at: within_day)
  end
end
