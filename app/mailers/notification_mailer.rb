# frozen_string_literal: true

class NotificationMailer < ApplicationMailer # rubocop:disable Metrics/ClassLength
  helper ApplicationHelper

  before_action do
    @mentionable = params[:mentionable]
    @comment = params[:comment]
    @receiver = params[:receiver]
    @message = params[:message]
    @check = params[:check]
    @product = params[:product]
    @answer = params[:answer]
    @announcement = params[:announcement]
    @question = params[:question]
    @report = params[:report]
    @sender = params[:sender]
    @event = params[:event]
    @page = params[:page]
    @regular_event = params[:regular_event]
  end

  # required params: comment, receiver, message
  def came_comment
    @user = @receiver
    link = "/#{@comment.commentable_type.downcase.pluralize}/#{@comment.commentable.id}"
    @notification = @user.notifications.find_by(link: link) || @user.notifications.find_by(link: "#{link}#latest-comment")
    mail to: @user.email, subject: "[FBC] #{@message}"
  end

  # required params: mentionable, receiver
  def mentioned
    @user = @receiver
    @notification = @user.notifications.find_by(link: @mentionable.path)
    subject = "[FBC] #{@mentionable.where_mention}で#{@mentionable.sender.login_name}さんからメンションがありました。"
    mail to: @user.email, subject: subject
  end

  # required params: check
  def checked
    @user = @check.receiver
    link = "/#{@check.checkable_type.downcase.pluralize}/#{@check.checkable.id}"
    @notification = @user.notifications.find_by(link: link)
    subject = "[FBC] #{@user.login_name}さんの#{@check.checkable.title}を確認しました。"
    mail to: @user.email, subject: subject
  end

  # required params: report, receiver
  def first_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    mail to: @user.email,
         subject: "[FBC] #{@report.user.login_name}さんがはじめての日報を書きました！"
  end

  # required params: sender, receiver
  def retired
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/users/#{@sender.id}")
    subject = "[FBC] #{@sender.login_name}さんが退会しました。"
    mail to: @user.email, subject: subject
  end

  # required params: report, receiver
  def trainee_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    subject = "[FBC] #{@report.user.login_name}さんが日報【 #{@report.title} 】を書きました！"
    mail to: @user.email, subject: subject
  end

  # required params: page, receiver
  def create_page
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/pages/#{@page.id}")
    subject = "[FBC] #{@page.user.login_name}さんがDocsに#{@page.title}を投稿しました。"
    mail to: @user.email, subject: subject
  end

  # required params: answer, receiver
  def chose_correct_answer
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/questions/#{@answer.question.id}")
    subject = "[FBC] #{@answer.receiver.login_name}さんの質問【 #{@answer.question.title} 】で#{@answer.sender.login_name}さんの回答がベストアンサーに選ばれました。"
    mail to: @user.email, subject: subject
  end

  # required params: report, receiver
  def consecutive_sad_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    mail to: @user.email,
         subject: "[FBC] #{@report.user.login_name}さんが#{User::DEPRESSED_SIZE}回連続でsadアイコンの日報を提出しました。"
  end

  # required params: sender, receiver
  def hibernated
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/users/#{@sender.id}", kind: Notification.kinds[:hibernated])
    subject = "[FBC] #{@sender.login_name}さんが休会しました。"
    mail to: @user.email, subject: subject
  end

  # required params: sender, receiver
  def signed_up
    @user = @receiver
    roles = @sender.roles_to_s.empty? ? '' : "(#{@sender.roles_to_s})"
    @notification = @user.notifications.find_by(link: "/users/#{@sender.id}", kind: Notification.kinds[:signed_up])
    subject = "[FBC] #{@sender.login_name}さん#{roles}が新しく入会しました！"
    mail to: @user.email, subject: subject
  end

  def update_regular_event
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/regular_events/#{@regular_event.id}", kind: Notification.kinds[:regular_event_updated])
    subject = "[FBC] 定期イベント【#{@regular_event.title}】が更新されました。"
    mail to: @user.email, subject: subject
  end

  # required params: question, receiver
  def no_correct_answer
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/questions/#{@question.id}", kind: Notification.kinds[:no_correct_answer])
    subject = "[FBC] #{@user.login_name}さんの質問【 #{@question.title} 】のベストアンサーがまだ選ばれていません。"
    mail to: @user.email, subject: subject
  end
end
