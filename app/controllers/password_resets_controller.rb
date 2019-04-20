# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  skip_before_action :require_login, raise: false

  def create
    @user = User.find_by(email: params[:email])
    if @user
      @user.deliver_reset_password_instructions!
      redirect_to login_path, notice: "パスワードの再設定についてのメールを送信しました"
    else
      redirect_to login_path, alert: "ユーザー名かパスワードが違います。"
    end
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password!(params[:user][:password])
      redirect_to login_path, notice: "パスワードが変更されました。"
    else
      render action: "edit"
    end
  end
end
