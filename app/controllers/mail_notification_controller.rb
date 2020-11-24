# frozen_string_literal: true

class MailNotificationController < ApplicationController
  def update
    user = User.find_by(unsubscribe_email_token: params[:token])

    if user.blank?
      redirect_to root_path, notice: "メール配信停止にはTOKENが必要です。"
    else
      user.mail_notification = false
      user.save!
      redirect_to root_path, notice: "メール配信を停止しました。"
    end
  end
end
