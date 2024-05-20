# frozen_string_literal: true

class RequestRetirement < ApplicationRecord
  attr_accessor :requester_email, :requester_name, :target_user_name

  belongs_to :user, optional: true
  belongs_to :target_user, class_name: 'User', optional: true

  NOT_EXISTENCE_MSG = 'は登録されていません。'

  validates :requester_name, presence: true
  validates :requester_name, inclusion: { in: ->(_) { User.pluck(:login_name) }, message: NOT_EXISTENCE_MSG }

  validates :requester_email, presence: true
  validates :requester_email, inclusion: { in: ->(_) { User.pluck(:email) }, message: NOT_EXISTENCE_MSG }

  validates :company_name, presence: true

  validates :target_user_name, presence: true
  validates :target_user_name, inclusion: { in: ->(_) { User.pluck(:login_name) }, message: NOT_EXISTENCE_MSG }

  validates :reason, presence: true

  validates :keep_data, inclusion: [true, false]

  validate :requester_name_and_email_must_match

  # フォームからはtarget_user_nameの属性で値を受け取る
  # 外部キーであるtarget_user_idの検証はこの時点では行えないため、別途target_user_nameを用いて検証。
  validate :target_user_is_unique

  after_validation :set_users

  private

  def requester_name_and_email_must_match
    requester_by_name = User.find_by(login_name: requester_name)
    requester_by_email = User.find_by(email: requester_email)
    errors.add(:base, 'アカウント名とメールアドレスのユーザー情報が一致しません。') unless requester_by_name == requester_by_email
  end

  def target_user_is_unique
    user = User.find_by(login_name: target_user_name)
    errors.add(:base, '既に退会申請済みのユーザーです。') if user && RequestRetirement.where(target_user_id: user.id).exists?
  end

  def set_users
    self.user = User.find_by(login_name: requester_name)
    self.target_user = User.find_by(login_name: target_user_name)
  end
end
