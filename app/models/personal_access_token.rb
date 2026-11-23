# frozen_string_literal: true

# ユーザーが自分で発行する個人アクセストークン。
# 実体はDoorkeeper::AccessTokenで、専用のOAuthアプリケーションに紐づけて保存する。
class PersonalAccessToken
  include ActiveModel::Model
  include ActiveModel::Attributes

  APPLICATION_NAME = '個人アクセストークン'
  REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'
  REQUIRED_SCOPE = 'read'
  APPLICATION_SCOPES = 'read write mentor admin'
  EXPIRATION_DAYS = [30, 90, 365].freeze
  DEFAULT_EXPIRATION_DAYS = 90
  SCOPE_LABELS = {
    'write' => '書き込み（write）',
    'mentor' => 'メンター用API（mentor）',
    'admin' => '管理者用API（admin）'
  }.freeze

  attr_accessor :user
  attr_reader :access_token

  attribute :scopes, default: -> { [] }
  attribute :expires_in_days, :integer, default: DEFAULT_EXPIRATION_DAYS

  validates :user, presence: true
  validate :expiration_must_be_selectable
  validate :scopes_must_be_available

  class << self
    def application
      Doorkeeper::Application.find_by(name: APPLICATION_NAME) ||
        Doorkeeper::Application.create!(
          name: APPLICATION_NAME,
          redirect_uri: REDIRECT_URI,
          scopes: APPLICATION_SCOPES
        )
    end

    def for_user(user)
      Doorkeeper::AccessToken
        .where(application: application, resource_owner_id: user.id, revoked_at: nil)
        .order(created_at: :desc)
    end

    def expiration_options
      EXPIRATION_DAYS.map { |days| ["#{days}日", days] }
    end

    def available_scopes(user)
      scopes = %w[read write]
      scopes << 'mentor' if user.admin_or_mentor?
      scopes << 'admin' if user.admin?
      scopes
    end
  end

  def scopes=(value)
    super(Array(value).map(&:to_s).compact_blank.uniq)
  end

  def save
    return false unless valid?

    @access_token = Doorkeeper::AccessToken.create!(
      application: self.class.application,
      resource_owner_id: user.id,
      scopes: ([REQUIRED_SCOPE] | scopes).join(' '),
      expires_in: expires_in_days.days.to_i
    )
    true
  end

  private

  def expiration_must_be_selectable
    return if EXPIRATION_DAYS.include?(expires_in_days)

    errors.add(:base, '有効期限は選択肢の中から選んでください。')
  end

  def scopes_must_be_available
    return if user.nil?

    unavailable = scopes - self.class.available_scopes(user)
    errors.add(:base, '指定できないスコープが含まれています。') if unavailable.any?
  end
end
