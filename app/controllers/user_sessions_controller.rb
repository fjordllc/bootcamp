# frozen_string_literal: true

class UserSessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = login(params[:user][:login], params[:user][:password], params[:remember])
    if @user
      if @user.retired_on?
        logout
        redirect_to retire_path
      else
        save_updated_at(@user)
        redirect_back_or_to root_url, notice: "ログインしました。"
      end
    else
      logout
      @user = User.new(
        login_name: params[:user][:login_name],
        password: params[:user][:password]
      )
      flash.now[:alert] = "ユーザー名かパスワードが違います。"
      render "new", notice: "ログアウトしました。"
    end
  end

  def destroy
    if current_user
      save_updated_at(current_user)
      logout
    end
    redirect_to root_url, notice: "ログアウトしました。"
  end

  def callback
    # auth = request.env['omniauth.auth']
    # github_token = auth[:credentials][:token]
    # user = find_or_register_github_token(github_token)
    binding.pry
    redirect_to root_path
  end

  private
    def save_updated_at(user)
      user.updated_at = Time.current
      user.save(validate: false)
    end
end
