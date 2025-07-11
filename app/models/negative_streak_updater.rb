# frozen_string_literal: true

class NegativeStreakUpdater
  def call(payload)
    report = payload[:report]
    report.user.update_negative_streak
  end
end
