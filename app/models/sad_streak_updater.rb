# frozen_string_literal: true

class SadStreakUpdater
  def call(report)
    report.user.update_sad_streak
  end
end
