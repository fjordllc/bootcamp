# frozen_string_literal: true

class JobSeekController < ApplicationController
  before_action :set_user, only: %i[update]
  before_action :set_redirect_url, only: %i[update]

  def update
    return unless current_user.admin?

    if @user.update(user_params)
      redirect_to @redirect_url, notice: "#{@user.login_name}の就職活動中の情報を更新しました。"
    else
      redirect_to @redirect_url, alert: "#{@user.login_name}の就職活動中の情報を更新できませんでした。"
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_redirect_url
    @redirect_url = request.referer || admin_users_url
  end

  def user_params
    params.require(:user).permit(:job_seeking)
  end
end
