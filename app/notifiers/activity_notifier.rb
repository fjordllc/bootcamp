# frozen_string_literal: true

class ActivityNotifier < ApplicationNotifier
  self.driver = ActivityDriver.new
  self.async_adapter = ActivityAsyncAdapter.new

  def graduated(params = {})
    params.merge!(@params)
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "🎉️ ️️#{sender.login_name}さんが卒業しました！",
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
    link = params[:link]

    notification(
      body: message,
      kind: :came_comment,
      receiver: receiver,
      sender: comment.sender,
      link: link,
      read: false
    )
  end

  def came_question(params = {})
    params.merge!(@params)
    question = params[:question]
    receiver = params[:receiver]

    notification(
      body: "#{question.user.login_name}さんから質問「#{question.title}」が投稿されました。",
      kind: :came_question,
      receiver: receiver,
      sender: question.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(question),
      read: false
    )
  end

  def submitted(params = {})
    params.merge!(@params)
    subject = params[:subject]
    receiver = params[:receiver]
    message = params[:message]

    notification(
      body: message,
      kind: :submitted,
      sender: subject.user,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(subject),
      read: false
    )
  end

  def create_page(params = {})
    params.merge!(@params)
    page = params[:page]
    receiver = params[:receiver]

    notification(
      body: "#{page.user.login_name}さんがDocsに#{page.title}を投稿しました。",
      kind: :create_pages,
      sender: page.sender,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(page),
      read: false
    )
  end

  def first_report(params = {})
    params.merge!(@params)
    report = params[:report]
    receiver = params[:receiver]

    notification(
      body: "🎉 #{report.user.login_name}さんがはじめての日報を書きました！",
      kind: :first_report,
      receiver: receiver,
      sender: report.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(report),
      read: false
    )
  end

  def post_announcement(params = {})
    params.merge!(@params)
    announce = params[:announce]
    receiver = params[:receiver]

    notification(
      body: "お知らせ「#{announce.title}」",
      kind: :announced,
      sender: announce.user,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(announce),
      read: false
    )
  end

  def retired(params = {})
    params.merge!(@params)
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "😢 #{sender.login_name}さんが退会しました。",
      kind: :retired,
      sender: sender,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

  def hibernated(params = {})
    params.merge!(@params)
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "#{sender.login_name}さんが休会しました。",
      kind: :hibernated,
      sender: sender,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

  def signed_up(params = {})
    params.merge!(@params)
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "🎉 #{sender.login_name}さんが新しく入会しました！",
      kind: :signed_up,
      sender: sender,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

  def mentioned(params = {})
    params.merge!(@params)
    mentionable = params[:mentionable]
    receiver = params[:receiver]

    notification(
      body: "#{mentionable.where_mention}で#{mentionable.sender.login_name}さんからメンションがきました。",
      kind: :mentioned,
      receiver: receiver,
      sender: mentionable.sender,
      link: mentionable.path,
      read: false
    )
  end

  def following_report(params = {})
    params.merge!(@params)
    report = params[:report]
    receiver = params[:receiver]

    notification(
      body: "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！",
      kind: :following_report,
      receiver: receiver,
      sender: report.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(report),
      read: false
    )
  end

  def came_answer(params = {})
    params.merge!(@params)
    answer = params[:answer]

    notification(
      body: "#{answer.user.login_name}さんから回答がありました。",
      kind: :answered,
      receiver: answer.receiver,
      sender: answer.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(answer.question),
      read: false
    )
  end

  def checked(params = {})
    params.merge!(@params)
    check = params[:check]
    receiver = params[:receiver]

    notification(
      body: "#{check.sender.login_name}さんが#{check.checkable.title}を確認しました。",
      kind: :checked,
      receiver: receiver,
      sender: check.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(check.checkable),
      read: false
    )
  end

  def trainee_report(params = {})
    params.merge!(@params)
    report = params[:report]
    receiver = params[:receiver]

    notification(
      body: "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！",
      kind: :trainee_report,
      receiver: receiver,
      sender: report.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(report),
      read: false
    )
  end

  def product_update(params = {})
    params.merge!(@params)
    product = params[:product]
    receiver = params[:receiver]

    notification(
      body: "#{product.user.login_name}さんの提出物が更新されました",
      kind: :product_update,
      receiver: receiver,
      sender: product.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(product),
      read: false
    )
  end

  def watching_notification(params = {})
    params.merge!(@params)
    watchable = params[:watchable]
    receiver = params[:receiver]
    sender = params[:comment].user
    action = watchable.instance_of?(Question) ? '回答' : 'コメント'
    notification(
      body: "#{watchable.user.login_name}さんの【 #{watchable.notification_title} 】に#{sender.login_name}さんが#{action}しました。",
      kind: :watching,
      receiver: receiver,
      sender: sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(watchable),
      read: false
    )
  end
end
