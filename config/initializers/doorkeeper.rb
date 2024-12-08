# frozen_string_literal: true

Doorkeeper.configure do
orm :active_record

  admin_authenticator do
    if current_user
      redirect_to root_path, alert: '管理者としてログインしてください' unless current_user.admin?
    else
      redirect_to login_path
    end
  end
end
