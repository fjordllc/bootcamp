# frozen_string_literal: true

class GraduationController < ApplicationController
  skip_before_action :require_login, raise: false
  skip_before_action :require_current_student, raise: false
  before_action :set_user, only: %i[update]
  before_action :set_redirect_url, only: %i[update]

  def update
    if @user.update(graduated_on: Date.current)
      Subscription.new.destroy(@user.subscription_id) if @user.subscription_id
      Newspaper.publish(:graduation_update, @user)
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
