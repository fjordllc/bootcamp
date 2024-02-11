# frozen_string_literal: true

class Learning < ApplicationRecord
  enum status: { unstarted: 0, started: 1, submitted: 2, complete: 3 }
  belongs_to :user, touch: true
  belongs_to :practice

  validates :user_id, presence: true
  validates :practice_id,
            presence: true,
            uniqueness: { scope: :user_id }
  validate :startable_practice

  private

  def startable_practice
    return unless started? && Learning.exists?(user_id:, status: 'started')

    errors.add :error, "すでに着手しているプラクティスがあります。\n提出物を提出するか修了すると新しいプラクティスを開始できます。"
  end
end
