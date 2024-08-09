# frozen_string_literal: true

class MailNotificationController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'not_logged_in'

  def confirm
    @user = User.find_by(unsubscribe_email_token: params[:token])
    redirect_to root_path, notice: 'メール配信停止にはTOKENが必要です。' unless @user
  end

  def update
    user = User.find(params[:user_id])
    user.mail_notification = false
    user.save!
    redirect_to root_path, notice: 'メール配信を停止しました。'
  end
end
