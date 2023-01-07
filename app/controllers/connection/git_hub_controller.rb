# frozen_string_literal: true

class Connection::GitHubController < ApplicationController
  skip_before_action :require_login, raise: false
  skip_before_action :require_current_student, raise: false

  def destroy
    current_user.update(github_id: nil)
    redirect_to root_path, notice: 'GitHubとの連携を解除しました。'
  end
end
