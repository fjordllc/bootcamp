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

    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.save(context: :reset_password)
      clear_password_token!
      redirect_to login_path, notice: "パスワードが変更されました。"
    else
      render action: "edit"
    end
  end

  private

    def clear_password_token!
      @user.update(
        reset_password_token: nil,
        reset_password_token_expires_at: nil
      )
    end
end
