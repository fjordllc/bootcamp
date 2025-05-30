# frozen_string_literal: true

class LearningTimeFrame < ApplicationRecord
  has_many :learning_time_frames_users, dependent: :destroy
  has_many :users, through: :learning_time_frames_users

  validates :week_day, :activity_time, presence: true

  scope :active_now, lambda {
    now = Time.zone.now
    weekday_map = {
      'sunday' => '日',
      'monday' => '月',
      'tuesday' => '火',
      'wednesday' => '水',
      'thursday' => '木',
      'friday' => '金',
      'saturday' => '土'
    }
    weekday = weekday_map[now.strftime('%A').downcase]
    hour = now.hour

    where(week_day: weekday, activity_time: hour)
  }
end
