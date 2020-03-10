# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :seat

  validates :seat_id, uniqueness: { scope: :date }
  validate :after_a_month
  validate :limit_reservations_to_five, unless: :admin_or_trainee?

  private
    def after_a_month
      if date > (Date.today.next_month)
        errors.add(:date, "は一ヶ月先までしか予約できません")
      end
    end

    def limit_reservations_to_five
      if date > Date.today && already_five_reservations?
        errors.add(:base, "明日以降の座席は最大５つまでしか予約できません")
      end
    end

    def admin_or_trainee?
      user.admin? || user.trainee?
    end

    def already_five_reservations?
      user.reservations.count { |reservation| reservation.date > Date.today } >= 5
    end
end
