# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  default from: "info@fjord.jp"
  add_template_helper(ApplicationHelper)

  def came_comment(comment, reciever, message)
    @comment = comment
    @user = reciever
    @message = message
    @notification = @user.notifications.find_by(path: "/#{@comment.commentable_type.downcase.pluralize}/#{@comment.commentable.id}")
    mail to: @user.email, subject: "[bootcamp] #{@message}"
  end

  def checked(check)
    @check = check
    @user = check.reciever
    @notification = @user.notifications.find_by(path: "/#{@check.checkable_type.downcase.pluralize}/#{@check.checkable.id}")
    mail to: @user.email, subject: "[bootcamp] #{@user.login_name}さんの#{@check.checkable.title}を確認しました。"
  end

  def mentioned(mention, reciever)
    @mention = mention
    @user = reciever
    @notification = @user.notifications.find_by(path: "/#{@mention.commentable_type.downcase.pluralize}/#{@mention.commentable.id}")
    mail to: @user.email, subject: "[bootcamp] #{@mention.sender.login_name}さんからメンションがきました。"
  end

  def submitted(product, reciever, message)
    @product = product
    @user = reciever
    @message = message
    @notification = @user.notifications.find_by(path: "/products/#{@product.id}")
    mail to: @user.email, subject: "[bootcamp] #{@message}"
  end

  def came_answer(answer)
    @answer = answer
    @user = answer.reciever
    @notification = @user.notifications.find_by(path: "/questions/#{@answer.question.id}")
    mail to: @user.email, subject: "[bootcamp] #{@answer.user.login_name}さんから回答がありました。"
  end

  def post_announcement(announce, reciever)
    @announce = announce
    @user = reciever
    @notification = @user.notifications.find_by(path: "/announcements/#{@announce.id}")
    mail to: @user.email, subject: "[bootcamp] #{@announce.user.login_name}さんからお知らせです。"
  end

  def came_question(question, reciever)
    @question = question
    @user = reciever
    @notification = @user.notifications.find_by(path: "/questions/#{@question.id}")
    mail to: @user.email, subject: "[bootcamp] #{@question.user.login_name}さんから質問がきました。"
  end

  def first_report(report, reciever)
    @report = report
    @user = reciever
    @notification = @user.notifications.find_by(path: "/reports/#{@report.id}")
    mail to: @user.email, subject: "[bootcamp] #{@report.user.login_name}さんがはじめての日報を書きました！"
  end

  def watching_notification(watchable, reciever)
    @watchable = watchable
    @user = reciever
    @notification = @user.notifications.find_by(path: "/#{@watchable.class.name.downcase.pluralize}/#{@watchable.id}")
    mail to: @user.email, subject: "[bootcamp] あなたがウォッチしている【 #{@watchable.title} 】にコメントが投稿されました。"
  end
end
