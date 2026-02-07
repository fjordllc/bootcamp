# frozen_string_literal: true

class Inquiry < ApplicationRecord
  include Commentable

  belongs_to :completed_by_user, class_name: 'User', optional: true

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
