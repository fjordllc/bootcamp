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

  def retired(params = {})
    params.merge!(@params)
    answer = params[:answer]
    receiver = params[:receiver]

    notification(
      body: "#{answer.receiver.login_name}さんの質問【 #{answer.question.title} 】で#{answer.sener.login_name}さんの回答がベストアンサーに選ばれました。",
      kind: :chose_correct_answer,
      sender: sender,
      receiver: receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

end
