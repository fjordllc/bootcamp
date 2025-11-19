# frozen_string_literal: true

class LearningTimeFrame < ApplicationRecord
  has_many :learning_time_frames_users, dependent: :destroy
  has_many :users, through: :learning_time_frames_users

  validates :week_day, :activity_time, presence: true

  scope :active_now, lambda {
    now = Time.current
    weekday = I18n.t('date.abbr_day_names')[now.wday]
    hour = now.hour

    where(week_day: weekday, activity_time: hour)
  }
end
