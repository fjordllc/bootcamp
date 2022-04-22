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
end
