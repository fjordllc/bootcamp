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
    @event = params[:event] if params&.key?(:event)
    @watchable = params[:watchable] if params&.key?(:watchable)
    @comment = params[:comment] if params&.key?(:comment)
    @product = params[:product] if params&.key?(:product)
    @report = params[:report] if params&.key?(:report)
    @regular_event = params[:regular_event] if params&.key?(:regular_event)
    @message = params[:message] if params&.key?(:message)
  end

  # required params: sender, receiver
  def comebacked(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]

    return false unless @receiver.mail_notification? # cancel sending email

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:comebacked]
    )
    subject = "[FBC] #{@sender.login_name}さんが休会から復帰しました。"
    mail to: @user.email, subject:
  end

  # required params: comment, message, receiver
  def came_comment(args = {})
    @comment ||= args[:comment]
    @message ||= args[:message]
    @receiver ||= args[:receiver]

    return unless @receiver.mail_notification?

    @user = @receiver
    link = "/#{@comment.commentable_type.downcase.pluralize}/#{@comment.commentable.id}"
    @link_url = notification_redirector_url(
      link:,
      kind: Notification.kinds[:came_comment]
    )
    mail to: @user.email, subject: "[FBC] #{@message}"
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
    mail to: @user.email, subject:
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
    message = mail(to: @user.email, subject:)
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
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  def came_question(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]
    @question ||= args[:question]

    @user = @receiver
    @title = @question.practice.present? ? "「#{@question.practice.title}」についての質問がありました。" : '質問がありました。'
    @link_url = notification_redirector_url(
      link: "/questions/#{@question.id}",
      kind: Notification.kinds[:came_question]
    )
    subject = "[FBC] #{@sender.login_name}さんから質問「#{@question.title}」が投稿されました。"
    message = mail(to: @user.email, subject:)

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
    message = mail(to: @user.email, subject:)
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
    message = mail(to: @user.email, subject:)
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
    message = mail(to: @user.email, subject:)
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

    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  def moved_up_event_waiting_user(args = {})
    @receiver ||= args[:receiver]
    @event ||= args[:event]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/events/#{@event.id}",
      kind: Notification.kinds[:moved_up_event_waiting_user]
    )
    subject = "[FBC] #{@event.title}で、補欠から参加に繰り上がりました。"
    message = mail(to: @user.email, subject:)
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

    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: sender, comment, watchable, receiver
  def watching_notification(args = {})
    @receiver ||= args[:receiver]
    @sender ||= args[:sender]
    @comment ||= args[:comment]
    @watchable ||= args[:watchable]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: @watchable.path,
      kind: Notification.kinds[:watched]
    )
    @action = @watchable.instance_of?(Question) ? '回答' : 'コメント'
    subject = "[FBC] #{@watchable.user.login_name}さんの#{@watchable.notification_title}に#{@sender.login_name}さんが#{@action}しました。"

    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?
    message
  end

  # required params: product, receiver
  def assigned_as_checker(args = {})
    @product ||= args[:product]
    @receiver ||= args[:receiver]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/products/#{@product.id}",
      kind: Notification.kinds[:assigned_as_checker]
    )

    subject = "[FBC] #{@product.user.login_name}さんの提出物#{@product.title}の担当になりました。"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: sender, receiver
  def hibernated(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:hibernated]
    )
    @hibernation = Hibernation.find_by(user_id: @sender.id)

    subject = "[FBC] #{@sender.login_name}さんが休会しました。"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?
    message
  end

  # required params: report, receiver
  def first_report(args = {})
    @report = params&.key?(:report) ? params[:report] : args[:report]
    @receiver ||= args[:receiver]
    @user = @receiver

    @link_url = notification_redirector_url(
      link: "/reports/#{@report.id}",
      kind: Notification.kinds[:first_report]
    )

    subject = "[FBC] #{@report.user.login_name}さんがはじめての日報を書きました！"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?
    message
  end

  # required params: report, receiver
  def consecutive_sad_report(args = {})
    @receiver ||= args[:receiver]
    @report ||= args[:report]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/reports/#{@report.id}",
      kind: Notification.kinds[:consecutive_sad_report]
    )
    subject = "[FBC] #{@report.user.login_name}さんが#{User::DEPRESSED_SIZE}回連続でsadアイコンの日報を提出しました。"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: regular_event, receiver
  def update_regular_event(args = {})
    @regular_event ||= args[:regular_event]
    @receiver ||= args[:receiver]
    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/regular_events/#{@regular_event.id}",
      kind: Notification.kinds[:regular_event_updated]
    )

    subject = "[FBC] 定期イベント【#{@regular_event.title}】が更新されました。"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: question, receiver
  def no_correct_answer(args = {})
    @question ||= args[:question]
    @receiver ||= args[:receiver]
    @user = @receiver

    @link_url = notification_redirector_url(
      link: "/questions/#{@question.id}",
      kind: Notification.kinds[:no_correct_answer]
    )

    subject = "[FBC] #{@user.login_name}さんの質問【 #{@question.title} 】のベストアンサーがまだ選ばれていません。"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: sender, receiver
  def signed_up(args = {})
    @sender ||= args[:sender]
    @receiver ||= args[:receiver]
    @sender_roles ||= args[:sender_roles]

    @user = @receiver
    @course_name = @sender.course[:title]

    @link_url = notification_redirector_url(
      link: "/users/#{@sender.id}",
      kind: Notification.kinds[:signed_up]
    )

    subject = "[FBC] #{@sender.login_name}さん#{@sender_roles}が#{@course_name}コースに入会しました！"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: answer, receiver
  def chose_correct_answer(args = {})
    @receiver ||= args[:receiver]
    @user = @receiver
    @answer = params&.key?(:answer) ? params[:answer] : args[:answer]

    @link_url = notification_redirector_url(
      link: question_path(@answer.question, anchor: "answer_#{@answer.id}"),
      kind: Notification.kinds[:chose_correct_answer]
    )

    subject = "[FBC] #{@answer.receiver.login_name}さんの質問【 #{@answer.question.title} 】で#{@answer.sender.login_name}さんの回答がベストアンサーに選ばれました。"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?
    message
  end

  # required params: product, receiver
  def product_update(args = {})
    @product = params&.key?(:product) ? params[:product] : args[:product]
    @receiver ||= args[:receiver]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/products/#{@product.id}",
      kind: Notification.kinds[:product_update]
    )
    subject = "[FBC] #{@product.user.login_name}さんが#{@product.title}を更新しました。"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?

    message
  end

  # required params: article, receiver
  def create_article(args = {})
    @article = params&.key?(:article) ? params[:article] : args[:article]
    @receiver ||= args[:receiver]

    @user = @receiver
    @link_url = notification_redirector_url(
      link: "/articles/#{@article.id}",
      kind: Notification.kinds[:create_article]
    )
    subject = "新しいブログ「#{@article.title}」を#{@article.user.login_name}さんが投稿しました！"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?
    message
  end

  # required params: work, receiver
  def added_work(args = {})
    @work = params&.key?(:work) ? params[:work] : args[:work]
    @receiver ||= args[:receiver]
    @user = @receiver

    @link_url = notification_redirector_url(
      link: "/works/#{@work.id}",
      kind: Notification.kinds[:added_work]
    )

    subject = "[FBC] #{@work.user.login_name}さんがポートフォリオに作品「#{@work.title}」を追加しました。"
    message = mail(to: @user.email, subject:)
    message.perform_deliveries = @user.mail_notification? && !@user.retired?
    message
  end
end
