# frozen_string_literal: true

# ユーザーのアカウント情報(認証・連携アカウント・添付ファイル)に関する責務をまとめたもの。
module UserAccount
  extend ActiveSupport::Concern

  included do
    belongs_to :company, optional: true
    belongs_to :course

    has_one :discord_profile, dependent: :destroy
    accepts_nested_attributes_for :discord_profile, allow_destroy: true

    has_many :oauth_access_grants,
             foreign_key: 'resource_owner_id',
             dependent: :delete_all,
             inverse_of: 'user'

    has_many :oauth_access_tokens,
             foreign_key: 'resource_owner_id',
             dependent: :delete_all,
             inverse_of: 'user'

    has_one_attached :avatar
    has_one_attached :profile_image
    has_one_attached :diploma_file

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
