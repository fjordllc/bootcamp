# frozen_string_literal: true

class UserIconsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  DEFAULT_ICON_PATH = '/images/users/avatars/default.png'

  def show
    user = User.find_by(login_name: params[:login_name])

    if user&.avatar&.attached?
      begin
        avatar_url = url_for(user.avatar.variant(resize_to_limit: [56, 56]))
      rescue ActiveStorage::FileNotFoundError, ActiveStorage::Error => e
        logger.error "[UserIcons] Avatar error for user #{user.login_name} (id=#{user.id}): #{e.class} - #{e.message}"
        expires_in 1.hour, public: true
        return redirect_to DEFAULT_ICON_PATH
      end
      expires_in 1.hour, public: true
      redirect_to avatar_url, allow_other_host: true
    else
      expires_in 1.hour, public: true
      redirect_to DEFAULT_ICON_PATH
    end
  end
end
