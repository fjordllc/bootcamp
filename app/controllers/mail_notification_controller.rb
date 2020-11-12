# frozen_string_literal: true

class MailNotificationController < ApplicationController
  def update
    user = User.find_by(unsubscribe_email_token: params[:token])
    user.mail_notification = false
    user.save!
    render :show
  end
end
