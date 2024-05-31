# frozen_string_literal: true

class Connection::GitHubController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def destroy
    user = User.find(params[:user_id])
    user.update(github_id: nil)
    redirect_to user_path(user), notice: 'GitHubとの連携を解除しました。'
  end
end
