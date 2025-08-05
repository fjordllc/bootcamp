# frozen_string_literal: true

class GraduationController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  before_action :set_user, only: %i[update]
  before_action :set_redirect_url, only: %i[update]
  before_action :require_admin_login, only: %i[update]

  def update
    if @user.update(graduated_on: Date.current)
      Subscription.new.destroy(@user.subscription_id) if @user.subscription_id
      ActiveSupport::Notifications.instrument('graduation.update', user: @user)
      redirect_to @redirect_url, notice: 'ユーザー情報を更新しました。'
    else
      redirect_to @redirect_url, alert: 'ユーザー情報の更新に失敗しました'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_redirect_url
    @redirect_url = params[:redirect_url].presence || admin_users_url
  end
end
