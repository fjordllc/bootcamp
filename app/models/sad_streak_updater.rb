# frozen_string_literal: true

class SadStreakUpdater
  def call(payload)
    report = payload[:report]
    report.user.update_sad_streak
  end
end
