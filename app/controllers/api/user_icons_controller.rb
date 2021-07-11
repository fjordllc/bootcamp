# frozen_string_literal: true

class API::UserIconsController < API::BaseController
  def show
    # user_icon_url = view_context.url_for(User.find_by(login_name: params[:login_name]).avatar)
    user_icon_url = rails_storage_proxy_url(User.find_by(login_name: params[:login_name]).avatar)
    render json: user_icon_url.to_json
  end
end
