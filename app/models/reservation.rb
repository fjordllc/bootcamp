# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :seat
  validates :user_id, uniqueness: { scope: :date, message: "は1人につき同じ日に1席のみ予約できます" }

  validate :after_a_month

  private
    def after_a_month
      if date > (Date.today.next_month)
        errors.add(:date, "は一ヶ月先までしか予約できません")
      end
    end
end
