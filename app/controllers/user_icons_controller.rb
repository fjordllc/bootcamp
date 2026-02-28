# frozen_string_literal: true

class UserIconsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  DEFAULT_ICON_PATH = '/images/users/avatars/default.png'

  def show
    user = User.find_by(login_name: params[:login_name])

    if user&.avatar&.attached?
      avatar_url = url_for(user.avatar.variant(resize_to_limit: [56, 56]))
      expires_in 1.hour, public: true
      redirect_to avatar_url, allow_other_host: true
    else
      expires_in 1.hour, public: true
      redirect_to DEFAULT_ICON_PATH
    end
  end
end
