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
    @notification = @user.notifications.find_by(link: link) || @user.notifications.find_by(link: "#{link}#latest-comment")
    mail to: @user.email, subject: "[FBC] #{@message}"
  end

  # required params: check
  def checked
    @user = @check.receiver
    link = "/#{@check.checkable_type.downcase.pluralize}/#{@check.checkable.id}"
    @notification = @user.notifications.find_by(link: link)
    subject = "[FBC] #{@user.login_name}さんの#{@check.checkable.title}を確認しました。"
    mail to: @user.email, subject: subject
  end

  # required params: mentionable, receiver
  def mentioned
    @user = @receiver
    @notification = @user.notifications.find_by(link: @mentionable.path)
    subject = "[FBC] #{@mentionable.where_mention}で#{@mentionable.sender.login_name}さんからメンションがありました。"
    mail to: @user.email, subject: subject
  end

  # required params: product, receiver, message
  def submitted
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/products/#{@product.id}")
    mail to: @user.email, subject: "[FBC] #{@message}"
  end

  # required params: answer
  def came_answer
    @user = @answer.receiver
    @notification = @user.notifications.find_by(link: "/questions/#{@answer.question.id}")
    mail to: @user.email, subject: "[FBC] #{@answer.user.login_name}さんから回答がありました。"
  end

  # required params: announcement, receiver
  def post_announcement
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/announcements/#{@announcement.id}")
    mail to: @user.email, subject: "[FBC] お知らせ「#{@announcement.title}」"
  end

  # required params: question, receiver
  def came_question
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/questions/#{@question.id}")
    mail to: @user.email, subject: "[FBC] #{@question.user.login_name}さんから質問「#{@question.title}」が投稿されました。"
  end

  # required params: report, receiver
  def first_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    mail to: @user.email,
         subject: "[FBC] #{@report.user.login_name}さんがはじめての日報を書きました！"
  end

  # required params: watchable, receiver
  def watching_notification
    @sender = @watchable.user
    @user = @receiver
    link = "/#{@watchable.class.name.underscore.pluralize}/#{@watchable.id}"
    @notification = @user.notifications.find_by(link: link)
    action = @watchable.instance_of?(Question) ? '回答' : 'コメント'
    subject = "[FBC] #{@sender.login_name}さんの【 #{@watchable.notification_title} 】に#{@comment.user.login_name}さんが#{action}しました。"
    mail to: @user.email, subject: subject
  end

  # required params: sender, receiver
  def retired
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/users/#{@sender.id}")
    subject = "[FBC] #{@sender.login_name}さんが退会しました。"
    mail to: @user.email, subject: subject
  end

  # required params: sender, receiver
  def three_months_after_retirement
    @notification = @receiver.notifications.find_by(link: "/users/#{@sender.id}")
    mail(to: @receiver.email, subject: default_i18n_subject(user: @sender.login_name.to_s))
  end

  # required params: report, receiver
  def trainee_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    subject = "[FBC] #{@report.user.login_name}さんが日報【 #{@report.title} 】を書きました！"
    mail to: @user.email, subject: subject
  end

  # required params: event, receiver
  def moved_up_event_waiting_user
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/events/#{@event.id}")
    subject = "[FBC] #{@event.title}で、補欠から参加に繰り上がりました。"
    mail to: @user.email, subject: subject
  end

  # required params: page, receiver
  def create_page
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/pages/#{@page.id}")
    subject = "[FBC] #{@page.user.login_name}さんがDocsに#{@page.title}を投稿しました。"
    mail to: @user.email, subject: subject
  end

  # required params: report, receiver
  def following_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    subject = "[FBC] #{@report.user.login_name}さんが日報【 #{@report.title} 】を書きました！"
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

  def assigned_as_checker
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/products/#{@product.id}")
    subject = "[FBC] #{@product.user.login_name}さんの提出物#{@product.title}の担当になりました。"
    mail to: @user.email, subject: subject
  end

  # required params: sender, receiver
  def graduated
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/users/#{@sender.id}", kind: Notification.kinds[:graduated])
    subject = "[FBC] #{@sender.login_name}さんが卒業しました。"
    mail to: @user.email, subject: subject
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
    @notification = @user.notifications.find_by(link: "/users/#{@sender.id}", kind: Notification.kinds[:signed_up])
    subject = "[FBC] #{@sender.login_name}さんが新しく入会しました！"
    mail to: @user.email, subject: subject
  end
end
