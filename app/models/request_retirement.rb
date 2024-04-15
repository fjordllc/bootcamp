# frozen_string_literal: true

class RequestRetirement < ApplicationRecord
  belongs_to :requester, class_name: 'User', optional: true
  belongs_to :target_user, class_name: 'User', optional: true

  validates :requester_email, presence: true
  validates :requester_name, presence: true
  validates :requester_company_name, presence: true
  validates :target_user_name, presence: true
  validates :reason_of_request_retirement, presence: true
  validates :keep_data, inclusion: [true, false]

  validate :user_existence

  private

  def user_existence
    message = 'は登録されていません。'

    if requester_registered? && target_user
      self.requester = user_by_requester_email
      self.target_user = target_user
    elsif !user_by_requester_email
      errors.add(:requester_email, message)
    elsif !user_by_requester_name
      errors.add(:requester_name, message)
    elsif !target_user
      errors.add(:target_user_name, message)
    end
  end

  def target_user
    User.find_by(login_name: target_user_name)
  end

  def requester_registered?
    user_by_requester_email && user_by_requester_name
  end

  def user_by_requester_email
    User.find_by(email: requester_email)
  end

  def user_by_requester_name
    User.find_by(login_name: requester_name)
  end
end
