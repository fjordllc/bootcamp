# frozen_string_literal: true

class Admin::JobSeeksController < ApplicationController
  before_action :set_user, only: %i[update]

  def update
    if @user.update(user_params)
      redirect_to talk_url, notice: "#{@user.login_name}の就職活動中の情報を更新しました。"
    else
      redirect_to talk_url, alert: "#{@user.login_name}の就職活動中の情報を更新できませんでした。"
    end
  end

  private

  def set_user
    @user = User.find(Talk.find(params[:id]).user_id)
  end

  def user_params
    params.require(:user).permit(:job_seeking)
  end
end
