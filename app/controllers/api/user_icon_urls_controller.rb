# frozen_string_literal: true

class API::UserIconUrlsController < API::BaseController
  def index
    users = User.with_attached_avatar
    user_icon_urls = {}
    users.each do |user|
      user_icon_urls.store(user.login_name, user.avatar.attached? ? rails_storage_proxy_url(user.avatar) : '')
    end
    render json: user_icon_urls.to_json
  end
end
