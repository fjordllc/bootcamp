# frozen_string_literal: true

class EventCallbacks
  def after_create(event)
    create_author_watch(event)
    notify_followers(event)

  end

  private

  def create_author_watch(event)
    Watch.create!(user: event.user, watchable: event)
  end

  def send_notification(product:, receivers:, message:)
    receivers.each do |receiver|
      NotificationFacade.submitted(product, receiver, message)
    end
  end

  def notify_followers(event)
    followers = event.user.followers
    send_notification(
      product: event,
      receivers: followers,
      message: "#{event.user.login_name}さんがイベント#{event.title}を作成しました。"
    )
    event.user.followers.each do |follower|
      create_following_watch(event, follower) if follower.watching?(event.user)
    end
  end

  def create_following_watch(event, follower)
    Watch.create!(user: follower, watchable: event)
  end
end
