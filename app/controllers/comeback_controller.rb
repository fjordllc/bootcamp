# frozen_string_literal: true

class ComebackController < ApplicationController
  skip_before_action :require_login, raise: false

  def new
    @user = User.new
  end

  def create
    @user = login(params[:user][:email], params[:user][:password])
    if @user
      if @user&.hibernated?
        @user.comeback!
        notify_to_mentors_and_admins(@user)
        redirect_to root_url, notice: '休会から復帰しました。'
      else
        @user = User.new
        flash.now[:alert] = '休会していないユーザーです。'
        render 'new'
      end
    else
      @user = User.new
      flash.now[:alert] = 'メールアドレスかパスワードが違います。'
      render 'new'
    end
  end

  private

  def notify_to_mentors_and_admins(user)
    User.admins_and_mentors.each do |admin_or_mentor|
      ActivityDelivery.with(sender: user, receiver: admin_or_mentor).notify(:comebacked)
    end
  end
end
