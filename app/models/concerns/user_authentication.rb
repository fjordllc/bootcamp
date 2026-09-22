# frozen_string_literal: true

# ユーザーのログイン認証に関する責務をまとめたもの。
module UserAuthentication
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
    validates :password, length: { minimum: 4 }, confirmation: true, if: :password_required?
    validates :github_id, uniqueness: true, allow_nil: true
  end

  private

  def password_required?
    new_record? || password.present?
  end
end
