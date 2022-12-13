# frozen_string_literal: true

class ActivityMailer < ApplicationMailer
  helper ApplicationHelper

  before_action do
    @sender = params[:sender] if params&.key?(:sender)
    @receiver = params[:receiver] if params&.key?(:receiver)
  end

  # required params: sender, receiver
  def graduated(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]

    @user = @receiver
    @notification = @user.notifications.find_by(link: "/users/#{@sender.id}", kind: Notification.kinds[:graduated])
    subject = "[FBC] #{@sender.login_name}さんが卒業しました。"
    mail to: @user.email, subject: subject
  end
end
