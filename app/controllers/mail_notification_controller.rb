# frozen_string_literal: true

class MailNotificationController < ApplicationController
  def update
    user = User.where(unsubscribe_email_token: params[:token]).first
    user.mail_notification = false
    user.save!
    render :show
  end
end
