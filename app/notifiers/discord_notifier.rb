# frozen_string_literal: true

class DiscordNotifier < ApplicationNotifier
  self.driver = DiscordDriver.new
  self.async_adapter = DiscordAsyncAdapter.new

  def graduated(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]

    notification(
      body: "#{params[:sender].login_name}さんが卒業しました。",
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def hibernated(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]

    notification(
      body: "#{params[:sender].login_name}さんが休会しました。",
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def announced(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:all]

    path = Rails.application.routes.url_helpers.polymorphic_path(params[:announce])
    url = "https://bootcamp.fjord.jp#{path}"

    notification(
      body: "お知らせ：「#{params[:announce].title}」\r#{url}",
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def tomorrow_regular_event(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]

    notification(
      body: params[:body],
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def invalid_user(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]
    body = params[:body].slice(0, 2000) # Discord API restriction

    notification(
      body: body,
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def payment_failed(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]

    notification(
      body: params[:body],
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def product_review_not_completed(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:mentor]
    comment = params[:comment]
    product_checker_name = User.find_by(id: comment.commentable.checker_id).login_name

    notification(
      body: " ⚠️ #{product_checker_name}さんが担当の#{comment.user.login_name}さんの「#{comment.commentable.practice.title}」の提出物が、最後のコメントから5日経過しました。",
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end
end
