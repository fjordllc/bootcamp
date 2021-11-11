# frozen_string_literal: true

class GraduationController < ApplicationController
  before_action :set_user, only: %i[update]

  def update
    if @user.update(graduated_on: Date.current)
      Subscription.new.destroy(@user.subscription_id) if @user.subscription_id

      notify_to_chat(@user)
      redirect_to admin_users_url, notice: 'ユーザー情報を更新しました。'
    else
      redirect_to admin_users_url, alert: 'ユーザー情報の更新に失敗しました'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def notify_to_chat(user)
    ChatNotifier.message(
      "「#{user.login_name}さんが卒業になりました」",
      webhook_url: ENV['DISCORD_ADMIN_WEBHOOK_URL']
    )
  end
end
