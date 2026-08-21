# frozen_string_literal: true

class NegativeStreakUpdater
  def call(_name, _started, _finished, _unique_id, payload)
    report = payload[:report]
    report.user.negative_streak_tracker.update_negative_streak
  end
end
