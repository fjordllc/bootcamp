class ExtendedTrial < ApplicationRecord
  validates :start_at, presence: true
  validates :end_at, presence: true

  with_options if: -> { start_at && end_at } do
    validate :end_at_be_greater_than_start_at
  end

  def self.extended_trial_term
    extended_trial_term = ExtendedTrial.order(end_at: :desc).first.term
  end

  def self.recently_extended_trial
    extended_trial = ExtendedTrial.order(end_at: :desc).first
    return if extended_trial == nil

    extended_trial.start_at..extended_trial.end_at
  end

  def self.today_is_extended_trial?
    return if recently_extended_trial == nil

    self.recently_extended_trial.cover?(Date.today)
  end

  private

  def end_at_be_greater_than_start_at
    diff = end_at - start_at
    return unless diff <= 0

    errors.add(:end_at, ': 終了日時は開始日時よりも後の日時にしてください。')
  end
end
