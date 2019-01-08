# frozen_string_literal: true

class Inquiry < ApplicationRecord
  validates :name, presence: true
  validates :email,
    presence: true,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "Emailに使える文字のみ入力してください"
    }
  validates :body, presence: true
end
