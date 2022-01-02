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
    @watchable = params[:watchable]
    @sender = params[:sender]
    @event = params[:event]
    @page = params[:page]
  end

  # required params: comment, receiver, message
  def came_comment
    @user = @receiver
    link = "/#{@comment.commentable_type.downcase.pluralize}/#{@comment.commentable.id}"
    @notification = @user.notifications.find_by(link: link)
    mail to: @user.email, subject: "[bootcamp] #{@message}"
  end

  # required params: check
  def checked
    @user = @check.receiver
    link = "/#{@check.checkable_type.downcase.pluralize}/#{@check.checkable.id}"
    @notification = @user.notifications.find_by(link: link)
    subject = "[bootcamp] #{@user.login_name}さんの#{@check.checkable.title}を確認しました。"
    mail to: @user.email, subject: subject
  end

  # required params: mentionable, receiver
  def mentioned
    @user = @receiver
    @notification = @user.notifications.find_by(link: @mentionable.path)
    subject = "[bootcamp] #{@mentionable.where_mention}で#{@mentionable.sender.login_name}さんからメンションがありました。"
    mail to: @user.email, subject: subject
  end

  # required params: product, receiver, message
  def submitted
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/products/#{@product.id}")
    mail to: @user.email, subject: "[bootcamp] #{@message}"
  end

  # required params: answer
  def came_answer
    @user = @answer.receiver
    @notification = @user.notifications.find_by(link: "/questions/#{@answer.question.id}")
    mail to: @user.email, subject: "[bootcamp] #{@answer.user.login_name}さんから回答がありました。"
  end

  # required params: announcement, receiver
  def post_announcement
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/announcements/#{@announcement.id}")
    mail to: @user.email, subject: "[bootcamp] お知らせ「#{@announcement.title}」"
  end

  # required params: question, receiver
  def came_question
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/questions/#{@question.id}")
    mail to: @user.email, subject: "[bootcamp] #{@question.user.login_name}さんから質問がありました。"
  end

  # required params: report, receiver
  def first_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    mail to: @user.email,
         subject: "[bootcamp] #{@report.user.login_name}さんがはじめての日報を書きました！"
  end

  # required params: watchable, receiver
  def watching_notification
    @sender = @watchable.user
    @user = @receiver
    link = "/#{@watchable.class.name.downcase.pluralize}/#{@watchable.id}"
    @notification = @user.notifications.find_by(link: link)
    subject = "[bootcamp] #{@sender.login_name}さんの【 #{@watchable.notification_title} 】に#{@comment.user.login_name}さんがコメントしました。"
    mail to: @user.email, subject: subject
  end

  # required params: sender, receiver
  def retired
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/users/#{@sender.id}")
    subject = "[bootcamp] #{@sender.login_name}さんが退会しました。"
    mail to: @user.email, subject: subject
  end

  # required params: report, receiver
  def trainee_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    subject = "[bootcamp] #{@report.user.login_name}さんが日報【 #{@report.title} 】を書きました！"
    mail to: @user.email, subject: subject
  end

  # required params: event, receiver
  def moved_up_event_waiting_user
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/events/#{@event.id}")
    subject = "[bootcamp] #{@event.title}で、補欠から参加に繰り上がりました。"
    mail to: @user.email, subject: subject
  end

  # required params: page, receiver
  def create_page
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/pages/#{@page.id}")
    subject = "[bootcamp] #{@page.user.login_name}さんがDocsに#{@page.title}を投稿しました。"
    mail to: @user.email, subject: subject
  end

  # required params: report, receiver
  def following_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    subject = "[bootcamp] #{@report.user.login_name}さんが日報【 #{@report.title} 】を書きました！"
    mail to: @user.email, subject: subject
  end

  # required params: answer, receiver
  def chose_correct_answer
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/questions/#{@answer.question.id}")
    subject = "[bootcamp] #{@answer.receiver.login_name}さんの質問【 #{@answer.question.title} 】で#{@answer.sender.login_name}さんの回答がベストアンサーに選ばれました。"
    mail to: @user.email, subject: subject
  end

  # required params: report, receiver
  def consecutive_sad_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    mail to: @user.email,
         subject: "[bootcamp] #{@report.user.login_name}さんが#{User::DEPRESSED_SIZE}回連続でsadアイコンの日報を提出しました。"
  end

  def assigned_as_checker
    @user = @receiver
    @notification = @user.notifications.find_by(path: "/products/#{@product.id}")
    subject = "[bootcamp] #{@product.user.login_name}さんの提出物#{@product.title}の担当になりました。"
    mail to: @user.email, subject: subject
  end
end
