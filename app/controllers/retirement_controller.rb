# frozen_string_literal: true

class RetirementController < ApplicationController
  def show
  end

  def new
  end

  def create
    current_user.assign_attributes(retire_reason_params)
    current_user.retired_on = Date.current
    if current_user.save
      Subscription.destroy(current_user.subscription_id) if current_user.subscription_id
      message = "<#{url_for(current_user)}|#{current_user.full_name} (#{current_user.login_name})>が退会しました。"
      SlackNotification.notify message,
        username: "#{current_user.login_name}@bootcamp.fjord.jp",
        icon_url: url_for(current_user.avatar)

      logout
      redirect_to retirement_url
    else
      render :new
    end
  end

  private
    def retire_reason_params
      params.require(:user).permit(:retire_reason)
    end
end
