# frozen_string_literal: true

class Hibernation < ApplicationRecord
  belongs_to :user
  validates :reason, presence: true
  validates :scheduled_return_on, presence: true

  def calculate_absence_days(user)
    return unless user.hibernated_at

    ((Time.zone.now - user.hibernated_at) / 86_400).floor
  end
end
