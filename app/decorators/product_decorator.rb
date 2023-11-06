# frozen_string_literal: true

module ProductDecorator
  include ActionView::Helpers::UrlHelper
  def list_title(resource)
    case resource
    when Practice
      user.login_name
    when User
      practice.title
    end
  end

  def reject_message_for_wrong_repository
    "中のPRのURLが間違っています。#{link_to '提出物のPRのやり方 - YouTube', 'https://www.youtube.com/watch?v=XMgLL4qIyEA'}を確認してPRを作り直してください"
  end
end
