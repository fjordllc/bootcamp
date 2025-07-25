# frozen_string_literal: true

class ArticleNotificationDestroyer
  def call(_name, _started, _finished, _unique_id, payload)
    article = payload[:article]
    Notification.where(link: "/articles/#{article.id}").destroy_all
  end
end
