# frozen_string_literal: true

class LearningTime < ApplicationRecord
  belongs_to :report
  validates :started_at, presence: true
  validates :finished_at, presence: true
  validate :learning_times_finished_at_be_greater_than_started_at

  before_validation :replace_date_with_reported_on
  before_validation :canonicalize_finished_at

  def diff
    finished_at - started_at
  end

  def learning_times_finished_at_be_greater_than_started_at
    if !report.wip? && diff <= 0
      errors.add(:finished_at, ": 終了時間は開始時間より後にしてください。")
    end
  end

  private

    def replace_date_with_reported_on
      report_date = report.reported_on
      self.started_at = started_at.change(year: report_date.year, month: report_date.month, day: report_date.day)
      self.finished_at = finished_at.change(year: report_date.year, month: report_date.month, day: report_date.day)
    end

    def canonicalize_finished_at
      if started_at > finished_at
        self.finished_at = finished_at + 1.day
      end
    end
end
