# frozen_string_literal: true

class LearningTime < ApplicationRecord
  belongs_to :report
  validates :started_at, presence: true
  validates :finished_at, presence: true

  def diff
    default = finished_at - started_at
    (default >= 0) ? default : (finished_at + 1.day) - started_at
  end
end
