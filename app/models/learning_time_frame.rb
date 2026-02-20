# frozen_string_literal: true

class LearningTimeFrame < ApplicationRecord
  WEEK_DAY_NAMES_JA = %w[日 月 火 水 木 金 土].freeze

  has_many :learning_time_frames_users, dependent: :destroy
  has_many :users, through: :learning_time_frames_users

  validates :week_day, :activity_time, presence: true

  scope :active_now, lambda {
    now = Time.current
    weekday = WEEK_DAY_NAMES_JA[now.wday]
    hour = now.hour

    where(week_day: weekday, activity_time: hour)
  }
end
