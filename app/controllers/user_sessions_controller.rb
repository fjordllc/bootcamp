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
        flash.now[:alert] = '退会したユーザーです。'
        render 'new'
      elsif @user.hibernated?
        logout
        flash.now[:alert] = '休会中です。休会復帰ページから手続きをお願いします。'
        render 'new'
      else
        redirect_back_or_to root_url, notice: 'ログインしました。'
      end
    else
      logout
      flash.now[:alert] = 'ユーザー名かパスワードが違います。'
      render 'new'
    end
  end

  def destroy
    logout if current_user
    redirect_to root_url, notice: 'ログアウトしました。'
  end

  # rubocop:disable Metrics/MethodLength
  def callback
    auth = request.env['omniauth.auth']
    github_id = auth[:uid]
    if current_user.blank?
      user = User.find_by(github_id: github_id)
      if user.blank?
        flash[:alert] = 'ログインに失敗しました。先にアカウントを作成後、GitHub連携を行ってください。'
        redirect_to root_url
      elsif user.retired_on?
        logout
        redirect_to retire_path
      else
        session[:user_id] = user.id
        redirect_back_or_to root_url, notice: 'サインインしました。'
      end
    else
      github_account = auth[:info][:nickname]
      current_user.register_github_account(github_id, github_account) if current_user.github_id.blank?
      flash[:notice] = 'GitHubと連携しました。'
      redirect_to root_path
    end
  rescue StandardError => e
    logger.warn "[GitHub Login] ログインに失敗しました。：#{e.message}"
    flash[:alert] = 'GitHubログインに失敗しました。数回試しても続く場合、管理者に連絡してください。'
    redirect_to root_path
  end
  # rubocop:enable Metrics/MethodLength
end
