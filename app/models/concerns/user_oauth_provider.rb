# frozen_string_literal: true

# ユーザーが外部アプリへOAuth経由でアクセスを許可する側(プロバイダー)としての責務をまとめたもの。
module UserOauthProvider
  extend ActiveSupport::Concern

  included do
    has_many :oauth_access_grants,
             foreign_key: 'resource_owner_id',
             dependent: :delete_all,
             inverse_of: 'user'

    has_many :oauth_access_tokens,
             foreign_key: 'resource_owner_id',
             dependent: :delete_all,
             inverse_of: 'user'
  end
end
