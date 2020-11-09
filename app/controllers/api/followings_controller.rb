# frozen_string_literal: true

class API::FollowingsController < API::BaseController
  include Rails.application.routes.url_helpers

  def create
    user = User.find(params[:id])
    if current_user.follow(user)
      render json: { id: user.id }
    else
      head :bad_request
    end
  end

  def destroy
    user = User.find(params[:id])
    if current_user.unfollow(user)
      head :no_content
    else
      head :bad_request
    end
  end
end
