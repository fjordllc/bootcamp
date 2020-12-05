# frozen_string_literal: true

class Connection::GitHubController < ApplicationController
  def destroy
    current_user.update(github_id: nil)
    redirect_to root_path, notice: 'GitHubとの連携を解除しました。'
  end
end
