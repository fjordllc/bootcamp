# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  helper ApplicationHelper
  helper MarkdownHelper

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

  # required params: mentionable, receiver
  def mentioned
    @user = @receiver
    @notification = @user.notifications.find_by(link: @mentionable.path)
    subject = "[FBC] #{@mentionable.where_mention}で#{@mentionable.sender.login_name}さんからメンションがありました。"
    mail to: @user.email, subject:
  end

  # required params: check
  def checked
    @user = @check.receiver
    link = "/#{@check.checkable_type.downcase.pluralize}/#{@check.checkable.id}"
    @notification = @user.notifications.find_by(link:)
    subject = "[FBC] #{@user.login_name}さんの#{@check.checkable.title}を確認しました。"
    mail to: @user.email, subject:
  end

  # required params: sender, receiver
  def retired
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/users/#{@sender.id}")
    subject = "[FBC] #{@sender.login_name}さんが退会しました。"
    mail to: @user.email, subject:
  end

  # required params: report, receiver
  def trainee_report
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/reports/#{@report.id}")
    subject = "[FBC] #{@report.user.login_name}さんが日報【 #{@report.title} 】を書きました！"
    mail to: @user.email, subject:
  end

  # required params: page, receiver
  def create_page
    @user = @receiver
    @notification = @user.notifications.find_by(link: "/pages/#{@page.id}")
    subject = "[FBC] #{@page.user.login_name}さんがDocsに#{@page.title}を投稿しました。"
    mail to: @user.email, subject:
  end
end
