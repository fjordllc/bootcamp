# frozen_string_literal: true

class ArticleNotificationDestroyer
  def call(payload)
    article = payload[:article]
    Notification.where(link: "/articles/#{article.id}").destroy_all
  end
end
