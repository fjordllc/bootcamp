class LearningTime < ApplicationRecord
  belongs_to :report
  validates :started_at, presence: true
  validates :finished_at, presence: true
  before_save :fix_finished_date

  def diff
    finished_at - started_at
  end

  private

  def fix_finished_date
    if finished_at_is_next_day_but_current_start_and_current_finish_is_same_day?
      self.finished_at += 1.day
    elsif finished_at_is_same_day_but_current_finish_is_next_day?
      self.finished_at -= 1.day
    end
  end

  def finished_at_is_next_day_but_current_start_and_current_finish_is_same_day?
    finished_at.hour < started_at.hour && to_date(finished_at) <= to_date(started_at)
  end

  def finished_at_is_same_day_but_current_finish_is_next_day?
    finished_at.hour >= started_at.hour && to_date(finished_at) > to_date(started_at)
  end

  def to_date(target)
    Date.new(target.year, target.month, target.day)
  end
end
