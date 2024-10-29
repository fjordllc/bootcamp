# frozen_string_literal: true

class Users::MailNotificationController < ApplicationController
  layout 'not_logged_in'

  def edit
    @user = User.find_by(unsubscribe_email_token: params[:token])
    redirect_to root_path, notice: 'メール配信停止にはTOKENが必要です。' unless @user
  end

  def update
    user_id = params[:user_id].to_i

    if current_user.id == user_id
      user = User.find(user_id)
      user.mail_notification = false
      user.save!
      redirect_to root_path, notice: 'メール配信を停止しました。'
    else
      redirect_to root_path, alert: '無効な操作です。'
    end
  end
end
