class LearningTime < ApplicationRecord
  belongs_to :report
  validates :started_at, presence: true
  validates :finished_at, presence: true

  def diff
    finished_at - started_at
  end
end
