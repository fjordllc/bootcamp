# frozen_string_literal: true

class GraduationController < ApplicationController
  before_action :set_user, only: %i[update]

  def update
    if @user.update(graduated_on: Date.current)
      Subscription.new.destroy(@user.subscription_id) if @user.subscription_id

      notify_to_mentors(@user)
      redirect_to @redirect_url, notice: 'ユーザー情報を更新しました。'
    else
      redirect_to @redirect_url, alert: 'ユーザー情報の更新に失敗しました'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
    @redirect_url = params[:redirect_url].presence || admin_users_url
  end

  def notify_to_mentors(user)
    User.mentor.each do |mentor|
      ActivityDelivery.with(sender: user, receiver: mentor).notify(:graduated)
    end
  end
end
