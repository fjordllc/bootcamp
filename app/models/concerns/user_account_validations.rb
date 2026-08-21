# frozen_string_literal: true

module UserAccountValidations
  extend ActiveSupport::Concern

  included do
    after_create UserCallbacks.new

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
    validates :name, presence: true
    validates :description, presence: true
    validates :nda, presence: true
    validates :password, length: { minimum: 4 }, confirmation: true, if: :password_required?
    validates :mail_notification, inclusion: { in: [true, false] }
    validates :show_mentor_profile, inclusion: { in: [true, false] }
    validates :github_id, uniqueness: true, allow_nil: true
  end

  private

  def password_required?
    new_record? || password.present?
  end
end
