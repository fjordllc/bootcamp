# frozen_string_literal: true

class SkipPractice < ApplicationRecord
  belongs_to :user
  belongs_to :practice

  validates :user_id, presence: true
  validates :practice_id,
            presence: true,
            uniqueness: { scope: :user_id }
  validate :practice_belongs_to_user

  private

  def practice_belongs_to_user
    return if user.practices.exists?(id: practice_id)

    errors.add(:practice, 'はユーザーが登録していないプラクティスです')
  end
end
