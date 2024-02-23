# frozen_string_literal: true

class API::FollowingsController < API::BaseController
  include Rails.application.routes.url_helpers

  def create
    user = User.find(params[:id])
    watch = params[:watch] == 'true'
    if current_user.follow(user, watch:)
      render json: { html: render_to_string(partial: 'users/following', locals: { user: }) }
    else
      head :bad_request
    end
  end

  def update
    user = User.find(params[:id])
    watch = params[:watch] == 'true'
    if current_user.change_watching(user, watch)
      render json: { html: render_to_string(partial: 'users/following', locals: { user: }) }
    else
      head :bad_request
    end
  end

  def destroy
    user = User.find(params[:id])
    if current_user.unfollow(user)
      render json: { html: render_to_string(partial: 'users/following', locals: { user: }) }
    else
      head :bad_request
    end
  end
end
