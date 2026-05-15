# frozen_string_literal: true

class ActivityDriver
  def call(params)
    Notification.create!(
      kind: Notification.kinds[params[:kind]],
      sender: params[:sender],
      user: params[:receiver],
      link: params[:link],
      message: params[:body],
      read: params[:read]
    )
  end
end
