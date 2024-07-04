# frozen_string_literal: true

class Connection::GitHubController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def destroy
    user = User.find(params[:user_id])
    if !admin_login? && user != current_user
      redirect_to root_path, alert: '管理者としてログインしてください'
    else
      user.update(github_id: nil)
      redirect_to user_path(user), notice: 'GitHubとの連携を解除しました。'
    end
  end
end
