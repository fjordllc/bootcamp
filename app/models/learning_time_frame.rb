# frozen_string_literal: true

class LearningTimeFrame < ApplicationRecord
  has_many :learning_time_frames_users, dependent: :destroy
  has_many :users, through: :learning_time_frames_users

  validates :week_day, :activity_time, presence: true
end
