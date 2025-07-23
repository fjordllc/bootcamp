# frozen_string_literal: true

class SadStreakUpdater
  ##
  # Updates the sad streak for the user associated with the provided report.
  # @param [Hash] payload - A hash containing the report whose user's sad streak should be updated.
  def call(_name, _started, _finished, _unique_id, payload)
    report = payload[:report]
    report.user.update_sad_streak
  end
end
