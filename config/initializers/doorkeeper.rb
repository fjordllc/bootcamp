# frozen_string_literal: true

Doorkeeper.configure do
orm :active_record
  resource_owner_authenticator do
    current_user || redirect_to(login_path)
  end

  admin_authenticator do
    if current_user
      redirect_to root_path, alert: '管理者としてログインしてください' unless current_user.admin?
    else
      redirect_to login_path
    end
  end

  # デフォルトのスコープを read に設定
  # これにより承認されたアプリケーションは API から公開データの「読み取り」が可能
  default_scopes :read
  enforce_configured_scopes
end
