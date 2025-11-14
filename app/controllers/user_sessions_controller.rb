# frozen_string_literal: true

class UserSessionsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def new
    @user = User.new
  end

  def create
    @user = login(params[:user][:login], params[:user][:password], params[:remember])
    if @user
      if @user.retired_on?
        logout_with_alert('退会したユーザーです。')
      elsif @user.training_completed?
        logout_with_alert('研修終了したユーザーです。')
      elsif @user.hibernated?
        link = view_context.link_to '休会復帰ページ', new_comeback_path, target: '_blank', rel: 'noopener'
        logout_with_alert("休会中です。#{link}から手続きをお願いします。")
      else
        redirect_back_or_to root_url, notice: 'ログインしました。'
      end
    else
      @user = User.new
      logout_with_alert('ユーザー名かパスワードが違います。')
    end
  end

  def destroy
    logout if current_user
    redirect_to root_path, notice: 'ログアウトしました。'
  end

  def callback
    auth = request.env['omniauth.auth']
    authentication =
      case params[:provider]
      when 'discord'
        Authentication::Discord.new(current_user, auth)
      when 'github'
        Authentication::Github.new(current_user, auth)
      end
    result = authentication.authenticate
    assign_flash_and_session(result)

    return redirect_back_or_to result[:path] if result[:back]

    redirect_to result[:path]
  end

  def failure
    redirect_to root_path, alert: 'キャンセルしました'
  end

  private

  def assign_flash_and_session(result)
    flash[:notice] = result[:notice] if result[:notice]
    flash[:alert] = result[:alert] if result[:alert]
    session[:user_id] = result[:user_id] if result[:user_id]
  end

  def logout_with_alert(message)
    logout
    flash.now[:alert] = message
    render 'new'
  end
end
