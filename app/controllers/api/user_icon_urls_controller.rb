# frozen_string_literal: true

class API::UserIconUrlsController < API::BaseController
  def index
    @users = set_user_icon
  end

  private

  def article_before_action?
    false
  end

  def set_user_icon
    users = User.with_attached_avatar
    logged_in? ? users : users.select {|test| !(test.avatar.blank?) }
  end
end
