# frozen_string_literal: true

class LearningTimeFrame < ApplicationRecord
  has_many :learning_time_frames_users, dependent: :destroy
  has_many :users, through: :learning_time_frames_users

  validates :week_day, :activity_time, presence: true

  scope :active_now, -> {
    now = Time.zone.now
    weekday = now.strftime('%A').downcase  # => "monday", "tuesday", ...
    hour = now.hour                        # => 10（現在の時間 0〜23）

    where(week_day: weekday, activity_time: hour)
  }
end
