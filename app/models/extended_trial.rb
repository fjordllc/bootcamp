class ExtendedTrial < ApplicationRecord
  has_many :users

  def self.extended_trial_term
    extended_trial_term = ExtendedTrial.order(end_at: :desc).first.term
  end

  def self.recently_extended_trial
    extended_trial = ExtendedTrial.order(end_at: :desc).first
    extended_trial.start_at..extended_trial.end_at
  end

  def self.today_is_extended_trial?
    self.recently_extended_trial.cover?(Date.today)
  end
end
