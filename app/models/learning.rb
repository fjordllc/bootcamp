# frozen_string_literal: true

class Learning < ActiveRecord::Base
  enum status: { not_complete: 0, started: 1, submitted: 2, complete: 3 }
  belongs_to :user, touch: true
  belongs_to :practice

  validates :user_id, presence: true
  validates :practice_id,
    presence: true,
    uniqueness: { scope: :user_id }
  validate :startable_practice

  def product_submitted
    if self.status != "complete"
      self.update(status: "submitted")
    end
  end

  def product_confirmed
    self.update(status: "complete")
  end

  private
    def startable_practice
      unless Learning.find_by(user_id: self.user_id, status: "started").nil? || self.status != "started"
        errors.add(:error, "すでに着手しているプラクティスがあります。\n提出物を提出するか完了すると新しいプラクティスを開始できます。")
      end
    end
end
