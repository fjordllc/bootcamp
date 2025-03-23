# frozen_string_literal: true

class GrantCourseApplication < ApplicationRecord
  include JpPrefecture
  include GrantCourseApplicationDecorator
  jp_prefecture :prefecture_code

  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :email,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: 'Emailに使える文字のみ入力してください'
            }
  validates :zip1, presence: true
  validates :zip2, presence: true
  validates :prefecture_code, presence: true
  validates :address1, presence: true
  validates :tel1, presence: true
  validates :tel2, presence: true
  validates :tel3, presence: true
  validates :privacy_policy, acceptance: true
end
