# frozen_string_literal: true

class UserSessionsController < ApplicationController
  def new
    @user = User.new
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
      @user = User.new(
        login_name: params[:user][:login_name],
        password: params[:user][:password]
      )
      flash.now[:alert] = "ユーザー名かパスワードが違います。"
      render "new", notice: "サインアウトしました。"
    end
  end

  def destroy
    if current_user
      save_updated_at(current_user)
      logout
    end
    redirect_to root_url, notice: "サインアウトしました。"
  end

  def callback
    auth = request.env['omniauth.auth']
    github_account = auth[:info][:nickname]
    if current_user.blank?
        user = User.find_by_github_account(github_account)
        if user.blank?
            flash[:notice] = "ログインに失敗しました。先にアカウントを作成後、GitHub連携を行ってください。"
            redirect_to root_url and return
        end
        session[:user_id] = user.id
        save_updated_at(user)
        redirect_back_or_to root_url, notice: "サインインしました。" and return
    else
        saved_account = current_user.github_account
        current_user.register_github_account(github_account) if saved_account.blank?
        flash[:notice] = "GitHubと連携しました。"
        redirect_to root_path and return
    end
  end

  private
    def save_updated_at(user)
      user.updated_at = Time.current
      user.save(validate: false)
    end
end
