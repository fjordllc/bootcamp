# frozen_string_literal: true

class Users::TalkController < ApplicationController
  def show
    @user = current_user.admin? ? User.find(params[:user_id]) : current_user

    return unless !current_user.admin? && params[:user_id].to_i != current_user.id

    redirect_to user_talk_path(current_user)
  end
end
