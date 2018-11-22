# frozen_string_literal: true

class UserSessionsController < ApplicationController
  def new
  end

  def create
    @user = login(params[:user][:login_name], params[:user][:password], params[:remember])
    if @user
      if @user.retired_on?
        logout
        redirect_to retire_path
      else
        save_updated_at(@user)
        redirect_back_or_to root_url, notice: "サインインしました。"
      end
    else
      logout
      flash.now[:alert] = "ユーザー名かパスワードが違います。"
      render "new", notice: "サインアウトしました。"
    end
  end

  def destroy
    save_updated_at(current_user)
    logout
    redirect_to root_url, notice: "サインアウトしました。"
  end

  private
    def save_updated_at(user)
      user.updated_at = Time.current
      user.save!
    end
end
