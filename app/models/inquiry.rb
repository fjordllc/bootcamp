# frozen_string_literal: true

class Inquiry < ApplicationRecord
  include Checkable
  scope :action_completed, -> { where(action_completed: true) }
  scope :not_completed, -> { where(action_completed: false) }
  include Commentable
  validates :name, presence: true
  validates :email,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: 'Emailに使える文字のみ入力してください'
            }
  validates :body, presence: true
  validates :privacy_policy, acceptance: { message: 'に同意してください' }
end
