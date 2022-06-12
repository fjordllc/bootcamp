# frozen_string_literal: true

class ActivityNotifier < ApplicationNotifier
  self.driver = ActivityDriver.new
  self.async_adapter = ActivityAsyncAdapter.new

  def graduated(params = {})
    params.merge!(@params)
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "#{sender.login_name}さんが卒業しました。",
      kind: :graduated,
      sender: sender,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

  def consecutive_sad_report(params = {})
    params.merge!(@params)
    report = params[:report]
    receiver = params[:receiver]

    notification(
      body: "#{report.user.login_name}さんが#{User::DEPRESSED_SIZE}回連続でsadアイコンの日報を提出しました。",
      kind: :consecutive_sad_report,
      sender: report.sender,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(report),
      read: false
    )
  end

  def assigned_as_checker(params = {})
    params.merge!(@params)
    product = params[:product]
    receiver = params[:receiver]

    notification(
      body: "#{product.user.login_name}さんの提出物#{product.title}の担当になりました。",
      kind: :assigned_as_checker,
      sender: product.sender,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(product),
      read: false
    )
  end

  def came_comment(params = {})
    params.merge!(@params)
    comment = params[:comment]
    receiver = params[:receiver]
    message = params[:message]

    notification(
      body: message,
      kind: :came_comment,
      receiver: receiver,
      sender: comment.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(comment.commentable),
      read: false
    )
  end
end
