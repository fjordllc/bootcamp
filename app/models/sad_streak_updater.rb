# frozen_string_literal: true

class SadStreakUpdater
  def call(user)
    user.update_sad_streak
  end
end
