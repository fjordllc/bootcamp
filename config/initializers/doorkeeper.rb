# frozen_string_literal: true

Doorkeeper.configure do
  orm :active_record
  resource_owner_authenticator do
    current_user || begin
      application = Doorkeeper.config.application_model.find_by(uid: params[:client_id])
      if application&.mcp_client? && request.fullpath.bytesize > McpOauth::AuthorizationsController::MAX_RETURN_TO_URL_BYTESIZE
        render json: { error: 'invalid_request' }, status: :bad_request
      else
        session[:return_to_url] = request.fullpath if application&.mcp_client?
        redirect_to(login_path)
      end
    end
  end

  admin_authenticator do
    if current_user
      redirect_to root_path, alert: '管理者としてログインしてください' unless current_user.admin?
    else
      redirect_to login_path
    end
  end

  # 本番・ステージング環境でもリダイレクトURLに「http://」を許可
  force_ssl_in_redirect_uri false

  # クライアントアプリが、BootCampアプリのリソースをどの範囲まで使用できるかを設定
  # Scopesのドキュメント：https://doorkeeper.gitbook.io/guides/ruby-on-rails/scopes
  # read = 読み取り, write = 書き込み, mentor = メンター業務, admin = 管理者業務
  default_scopes :read # Scopesが未設定（空白）の場合、設定されるスコープ

  optional_scopes :write, :mentor, :admin, :'mcp:practices:read' # Scopesで指定されたときに設定されるスコープ

  # MCP の発行先を認可コードからアクセストークンへ引き継ぐ。
  custom_access_token_attributes [:resource]

  # defalut_scopeとoptional_scopeで定義されたスコープのみ要求できるようになる
  enforce_configured_scopes

  # 更新トークンの初回発行だけを専用の読み取りクライアントに許可する。
  # 設定解除では既発行トークンは失効しないため、停止時は明示的に失効させる。
  use_refresh_token do |context|
    uid = ENV['BOOTCAMP_REFRESH_CLIENT_UID']
    client = context.client

    uid.present? && client&.confidential? && !client.mcp_client? && client.uid == uid &&
      client.scopes.to_s == 'read' && context.scopes.to_s == 'read' &&
      context.grant_type == 'authorization_code' && context.resource_owner.present?
  end
end
