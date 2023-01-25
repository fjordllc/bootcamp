# frozen_string_literal: true

class ActivityMailer < ApplicationMailer
  helper ApplicationHelper
  include Rails.application.routes.url_helpers

  before_action do
    @sender = params[:sender] if params&.key?(:sender)
    @receiver = params[:receiver] if params&.key?(:receiver)
    @announcement = params[:announcement] if params&.key?(:announcement)
  end

  # required params: sender, receiver
  def graduated(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]

    return false unless @receiver.mail_notification? # cancel sending email

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:graduated]
    )
    subject = "[FBC] #{@sender.login_name}さんが卒業しました。"
    mail to: @user.email, subject: subject
  end

  # required params: answer
  def came_answer(args = {})
    @answer = params&.key?(:answer) ? params[:answer] : args[:answer]
    @user = @answer.receiver
    @link_url = notification_redirector_url(
      link: "/questions/#{@answer.question.id}",
      kind: Notification.kinds[:answered]
    )
    message = mail to: @user.email, subject: "[FBC] #{@answer.user.login_name}さんから回答がありました。"
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: announcement, receiver
  def post_announcement(args = {})
    @receiver ||= args[:receiver]
    @announcement ||= args[:announcement]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/announcements/#{@announcement.id}",
      kind: Notification.kinds[:announced]
    )
    subject = "[FBC] お知らせ「#{@announcement.title}」"
    message = mail to: @user.email, subject: subject
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  def came_question(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]
    @question = params[:question]

    @user = @receiver
    @link_url = notification_redirector_path(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:came_question]
    )
    subject = "[FBC] #{@sender.login_name}さんから質問「#{@question.title}」が投稿されました。"
    mail to: @user.email, subject: subject
  end
end
