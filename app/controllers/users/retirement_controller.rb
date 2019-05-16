# frozen_string_literal: true

class Users::RetirementController < ApplicationController
  def show
  end

  def new
    @user = User.find(params[:user_id])
  end

  def create
    @user = User.find(params[:user_id])
    @user.assign_attributes(retire_reason_params)
    @user.retired_on = Date.current
    if @user.save(context: :retire_reason_presence)
      Subscription.destroy(@user.subscription_id)

      message = "<#{url_for(@user)}|#{@user.full_name} (#{@user.login_name})>が退会しました。"
      SlackNotification.notify message,
        username: "#{@user.login_name}@bootcamp.fjord.jp",
        icon_url: url_for(@user.avatar)

      logout
      redirect_to user_retirement_url(@user)
    else
      render :new
    end
  end

  private
    def retire_reason_params
      params.require(:user).permit(:retire_reason)
    end
end
