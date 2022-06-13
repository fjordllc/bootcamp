# frozen_string_literal: true

class API::UserIconUrlsController < API::BaseController
  def index
    @users = set_user_icon
  end

  private

  def set_user_icon
    users = User.with_attached_avatar
    logged_in? ? users : users.select { |user| user.avatar.present? }
  end

  def not_before_user_icon_urls_controller?
    false
  end
end
