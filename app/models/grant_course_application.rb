# frozen_string_literal: true

class GrantCourseApplication < ApplicationRecord
  validates :name, presence: true
  validates :email,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: 'Emailに使える文字のみ入力してください'
            }
  validates :address, presence: true
  validates :phone, presence: true
  validates :privacy_policy, acceptance: { message: 'に同意してください' }

  def sender_name_and_email
    "#{name} (#{email})"
  end
end
