# frozen_string_literal: true

class ActivityMailer < ApplicationMailer
  helper ApplicationHelper
  include Rails.application.routes.url_helpers

  before_action do
    @sender = params[:sender] if params&.key?(:sender)
    @receiver = params[:receiver] if params&.key?(:receiver)
    @check = params[:check] if params&.key?(:check)
    @announcement = params[:announcement] if params&.key?(:announcement)
    @question = params[:question] if params&.key?(:question)
    @mentionable = params[:mentionable] if params&.key?(:mentionable)
    @page = params[:page] if params&.key?(:page)
    @report = params[:report] if params&.key?(:report)
  end

  # required params: sender, receiver
  def comebacked(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]

    return false unless @receiver.mail_notification? # cancel sending email

    @link_url = notification_redirector_url(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:comebacked]
    )
    subject = "[FBC] #{@sender.login_name}さんが休会から復帰しました。"
    mail to: @receiver.email, subject: subject
  end

  # required params: sender, receiver
  def graduated(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]

    return false unless @receiver.mail_notification? # cancel sending email

    @link_url = notification_redirector_url(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:graduated]
    )
    subject = "[FBC] #{@sender.login_name}さんが卒業しました。"
    mail to: @receiver.email, subject: subject
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

  # required params: product, receiver
  def submitted(args = {})
    @product = params&.key?(:product) ? params[:product] : args[:product]
    @receiver ||= args[:receiver]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/products/#{@product.id}",
      kind: Notification.kinds[:submitted]
    )
    subject = "[FBC] #{@product.user.login_name}さんが#{@product.title}を提出しました。"
    message = mail to: @user.email, subject: subject
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: announcement, receiver
  def post_announcement(args = {})
    @receiver ||= args[:receiver]
    @announcement ||= args[:announcement]

    @link_url = notification_redirector_url(
      link: "/announcements/#{@announcement.id}",
      kind: Notification.kinds[:announced]
    )
    subject = "[FBC] お知らせ「#{@announcement.title}」"
    message = mail to: @receiver.email, subject: subject
    message.perform_deliveries = @receiver.mail_notification? && !@receiver.retired?

    message
  end

  # required params: sender, receiver
  def three_months_after_retirement(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]

    @link_url = notification_redirector_url(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:retired]
    )
    message = mail(to: @receiver.email, subject: default_i18n_subject(user: @sender.login_name.to_s))
    message.perform_deliveries = @receiver.mail_notification? && !@receiver.retired?

    message
  end

  def came_question(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]
    @question ||= args[:question]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/questions/#{@question.id}",
      kind: Notification.kinds[:came_question]
    )
    subject = "[FBC] #{@sender.login_name}さんから質問「#{@question.title}」が投稿されました。"
    message = mail to: @user.email, subject: subject

    message.perform_deliveries = @user.mail_notification? && !@user.retired?
    message
  end

  # required params: sender, receiver
  def retired(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:retired]
    )
    subject = "[FBC] #{@sender.login_name}さんが退会しました。"
    message = mail to: @user.email, subject: subject
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: check, receiver
  def checked(args = {})
    @check ||= args[:check]
    @receiver ||= args[:receiver]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/users/#{@user.id}",
      kind: Notification.kinds[:checked]
    )
    subject = "[FBC] #{@user.login_name}さんの#{@check.checkable.title}を確認しました。"
    message = mail to: @user.email, subject: subject
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: mentionable, receiver
  def mentioned(args = {})
    @mentionable ||= args[:mentionable]
    @receiver ||= args[:receiver]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: @mentionable.path,
      kind: Notification.kinds[:mentioned]
    )
    subject = "[FBC] #{@mentionable.where_mention}で#{@mentionable.sender.login_name}さんからメンションがありました。"
    message = mail to: @user.email, subject: subject
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: page, receiver
  def create_page(args = {})
    @receiver ||= args[:receiver]
    @page ||= args[:page]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/pages/#{@page.id}",
      kind: Notification.kinds[:create_pages]
    )
    subject = "[FBC] #{@page.user.login_name}さんがDocsに#{@page.title}を投稿しました。"

    message = mail to: @user.email, subject: subject
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  def following_report(args = {})
    @sender ||= args[:sender]
    @report = params&.key?(:report) ? params[:report] : args[:report]
    @receiver ||= args[:receiver]
    @user = @receiver

    @link_url = notification_redirector_url(
      link: "/reports/#{@report.id}",
      kind: Notification.kinds[:following_report]
    )
    subject = "[FBC] #{@report.user.login_name}さんが日報【 #{@report.title} 】を書きました！"

    message = mail to: @user.email, subject: subject
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: report, receiver
  def first_report(args = {})
    @receiver ||= args[:receiver]
    @report ||= args[:report]

    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    mail to: @user.email,
         subject: "[FBC] #{@report.user.login_name}さんがはじめての日報を書きました！"
  end
end
