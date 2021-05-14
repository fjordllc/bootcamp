# frozen_string_literal: true

class LearningTime < ApplicationRecord
  belongs_to :report
  validates :started_at, presence: true
  validates :finished_at, presence: true
  validate :learning_times_finished_at_be_greater_than_started_at

  def diff
    finished_at - started_at
  end

  def learning_times_finished_at_be_greater_than_started_at
    return unless !report.wip? && diff.negative?

    errors.add(:finished_at, ': 終了時間は開始時間より後にしてください。')
  end
end
