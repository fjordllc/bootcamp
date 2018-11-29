# frozen_string_literal: true

class LearningTime < ApplicationRecord
  belongs_to :report
  validates :started_at, presence: true
  validates :finished_at, presence: true
  validate :learning_times_finished_at_be_greater_than_started_at

  def diff
    default = finished_at - started_at
    (default >= 0) ? default : (finished_at + 1.day) - started_at
  end

  def learning_times_finished_at_be_greater_than_started_at
    if !report.wip? && diff <= 0
      errors.add(:finished_at, ": 終了時間は開始時間より後にしてください。")
    end
  end
end
