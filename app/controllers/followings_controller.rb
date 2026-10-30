# frozen_string_literal: true

class FollowingsController < ApplicationController
  include Rails.application.routes.url_helpers

  def create
    @user = User.find(params[:id])
    watch = params[:watch] == 'true'
    head :bad_request unless current_user.follow(@user, watch:)&.persisted?
  end

  def update
    @user = User.find(params[:id])
    watch = params[:watch] == 'true'
    head :bad_request unless current_user.change_watching(@user, watch)
  end

  def destroy
    @user = User.find(params[:id])
    if current_user.following?(@user)
      current_user.unfollow(@user)
    else
      head :bad_request
    end
  end
end
