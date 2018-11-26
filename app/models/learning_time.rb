# frozen_string_literal: true

class LearningTime < ApplicationRecord
  belongs_to :report
  validates :started_at, presence: true
  validates :finished_at, presence: true
  validate :finished_at_be_greater_than_started_at

  def finished_at_be_greater_than_started_at
    return if report.wip? || diff > 0
    return if diff > 0
    errors.add(:finished_at, ": 学習時間0時間は登録できません")
  end

  def diff
    default = finished_at - started_at
    (default >= 0) ? default : (finished_at + 1.day) - started_at
  end
end
