# frozen_string_literal: true

class SadStreakUpdater
  def call(_name, _started, _finished, _unique_id, payload)
    report = payload[:report]
    report.user.update_sad_streak
  end
end
