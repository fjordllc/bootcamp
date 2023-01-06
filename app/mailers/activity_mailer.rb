# frozen_string_literal: true

class ActivityMailer < ApplicationMailer
  helper ApplicationHelper
  include Rails.application.routes.url_helpers

  before_action do
    @comment = params[:comment] if params&.key?(:comment)
    @message = params[:message] if params&.key?(:message)
    @sender = params[:sender] if params&.key?(:sender)
    @receiver = params[:receiver] if params&.key?(:receiver)
  end

  # required params: comment, message, receiver
  def came_comment(args = {})
    @comment ||= args[:comment]
    @message ||= args[:message]
    @receiver ||= args[:receiver]

    @user = @receiver
    link = "/#{@comment.commentable_type.downcase.pluralize}/#{@comment.commentable.id}"
    @link_url = notification_redirector_path(
      link: link,
      kind: Notification.kinds[:came_comment]
    )
    mail to: @user.email, subject: "[FBC] #{@message}"
  end

  # required params: sender, receiver
  def graduated(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]

    @user = @receiver
    @link_url = notification_redirector_path(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:graduated]
    )
    subject = "[FBC] #{@sender.login_name}さんが卒業しました。"
    mail to: @user.email, subject: subject
  end
end
