# frozen_string_literal: true

class API::UserIconUrlsController < API::BaseController
  skip_before_action :require_login_for_api

  def index
    @users = set_user_icon
  end

  private

  def set_user_icon
    users = User.with_attached_avatar
    logged_in? ? users : users.select { |user| user.avatar.present? }
  end
end
