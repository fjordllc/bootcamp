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

  # クライアントアプリが、BootCampアプリのリソースをどの範囲まで使用できるかを設定
  # Scopesのドキュメント：https://doorkeeper.gitbook.io/guides/ruby-on-rails/scopes
  # read = 読み取り, write = 書き込み 
  default_scopes :read # Scopesが未設定（空白）の場合、設定されるスコープ
  
  optional_scopes :write # Scopesで指定されたときに設定されるスコープ


  # defalut_scopeとoptional_scopeで定義されたスコープのみ要求できるようになる
  enforce_configured_scopes
end
